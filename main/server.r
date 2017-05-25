library(shiny)

source("library.R")

# Załadowanie zbiorów danych
gf_2016 = read.csv("data/ESC-2016-grand_final-full_results.csv", header = TRUE)
sf1_2016 = read.csv("data/ESC-2016-first_semi-final-full_results.csv", header = TRUE)
sf2_2016 = read.csv("data/ESC-2016-second_semi-final-full_results.csv", header = TRUE)
map = readOGR("data/custom.geojson", "OGRGeoJSON")

# Lista możliwych turniejów do wyboru do funkcji choose_country
tournaments <- c("sf1_2016", "sf2_2016", "gf_2016")

shinyServer(function(input, output) {
	# Funkcja pozwalająca wybierać kraje w zależności od wybranego turnieju
	output$choose_country <- renderUI({

		if(is.null(input$lev))
		return()

		dat <- get(input$lev)
		dat <- dat[order(dat$To.country),]
		country_names <- "all"
		country_names <- union(country_names, unique(dat$To.country))

		radioButtons("country", label = h3("Choose country"), 
						choices  = country_names,
						selected = "all")
	})

	output$Plot_All <- renderPlot({

		# Wybór danych
		data_set<-get(input$lev)

		# Agregacja zmiennych jury i televote po kraju
		jury<-aggregate(data_set$Jury.Points, by=list(Category=data_set$To.country), FUN=sum, na.rm=TRUE, na.action=NULL)
		televote<-aggregate(data_set$Televote.Points, by=list(Category=data_set$To.country), FUN=sum, na.rm=TRUE, na.action=NULL)

		# Renamey zmiennych
		jury$jury<-jury$x
		jury$country<-jury$Category
		televote$televote<-televote$x
		televote$country<-televote$Category

		# Obliczenie zmiennej both jako sumy głosów telewidzów i jury
		punkty<-merge(x=jury, y=televote, by="country")
		punkty$both<-coalesce(punkty$jury,0) + coalesce(punkty$televote,0)

		# Stworzenie zbioru do rysowania wykresów
		map$country<-map$sovereignt
		final_data_set<-merge(x=map, y=punkty, by="country", all.x=TRUE)

		# Stworzenie kolorów
		zmienna<-final_data_set$both
		# Ponieważ zaczynał rysować wykresy od -1.33
		zmienna[zmienna <= 0] <- NA
		przedzialy<-9
		kolory<-brewer.pal(przedzialy, "YlOrRd")
		klasy<-classIntervals(zmienna, przedzialy, style="pretty", intervalClosure="right", digits=1)
		tabela.kolorów<-findColours(klasy, kolory) 

		# Rysowanie wykresu
		plot(final_data_set, ylim=c(30, 75), xlim=c(0, 40), col=tabela.kolorów)
		legend("bottomleft", legend=names(attr(tabela.kolorów, "table")), fill=attr(tabela.kolorów, "palette"), cex=1, bty="n")

	})

	output$Plot_Gained <- renderPlot({

		# Wybór danych
		data_set<-get(input$lev)

		# Obliczenie zmiennej both jako sumy głosów telewidzów i jury
		dat_to<-data_set[data_set$To.country == input$country,]
		dat_to$both<-coalesce(dat_to$Jury.Points,0) + coalesce(dat_to$Televote.Points,0)
		dat_to$country<-dat_to$ď.żFrom.country

		# Stworzenie zbioru do rysowania wykresów
		map$country<-map$sovereignt
		final_data_set_to<-merge(x=map, y=dat_to, by="country", all.x=TRUE)

		# Stworzenie kolorów
		zmienna<-final_data_set_to$both
		# Ponieważ zaczynał rysować wykresy od -1.33
		zmienna[zmienna <= 0] <- NA
		przedzialy<-9
		kolory<-brewer.pal(przedzialy, "YlOrRd")
		klasy<-classIntervals(zmienna, przedzialy, style="pretty", intervalClosure="right", digits=1)
		tabela.kolorów<-findColours(klasy, kolory) 

		# Rysowanie wykresu
		plot(final_data_set_to, ylim=c(30, 75), xlim=c(0, 40), col=tabela.kolorów)
		legend("bottomleft", legend=names(attr(tabela.kolorów, "table")), fill=attr(tabela.kolorów, "palette"), cex=1, bty="n")
	})

	output$Plot_Given <- renderPlot({

		# Wybór danych
		data_set<-get(input$lev)

		# Obliczenie zmiennej both jako sumy głosów telewidzów i jury
		dat_from<-data_set[data_set$ď.żFrom.country == input$country,]
		dat_from$both<-coalesce(dat_from$Jury.Points,0) + coalesce(dat_from$Televote.Points,0)
		dat_from$country<-dat_from$To.country

		# Stworzenie zbioru do rysowania wykresów
		map$country<-map$sovereignt
		final_data_set_from<-merge(x=map, y=dat_from, by="country", all.x=TRUE)

		# Stworzenie kolorów
		zmienna<-final_data_set_from$both
		# Ponieważ zaczynał rysować wykresy od -1.33
		zmienna[zmienna <= 0] <- NA
		przedzialy<-9
		kolory<-brewer.pal(przedzialy, "YlOrRd")  # wybór kolorów
		klasy<-classIntervals(zmienna, przedzialy, style="pretty", intervalClosure="right", digits=1)
		tabela.kolorów<-findColours(klasy, kolory) 

		# Rysowanie wykresu
		plot(final_data_set_from, ylim=c(30, 75), xlim=c(0, 40), col=tabela.kolorów)
		legend("bottomleft", legend=names(attr(tabela.kolorów, "table")), fill=attr(tabela.kolorów, "palette"), cex=1, bty="n")
	})

	output$data_table_gained <- renderTable({

		# Wybór danych
		data_set<-get(input$lev)

		# Obliczenie zmiennej both jako sumy głosów telewidzów i jury
		dat_to<-data_set[data_set$To.country == input$country,]
		dat_to$both<-coalesce(dat_to$Jury.Points,0) + coalesce(dat_to$Televote.Points,0)
		dat_to$country<-dat_to$ď.żFrom.country

		# Stworzenie zbioru do pokazania danych
		map$country<-map$sovereignt
		final_data_set_to<-merge(x=map, y=dat_to, by="country", all.x=TRUE)

		# Lista kolumn do pokazania
		cols<-c("country", "jury", "televote", "both")

		# Renamey kolumn
		final_data_set_to$jury<-final_data_set_to$Jury.Points
		final_data_set_to$televote<-final_data_set_to$Televote.Points

		# Wybór obserwacji i kolumn do pokazania
		final_data_set_to <- final_data_set_to[, cols, drop = FALSE]
		final_data_set_to <- final_data_set_to[!is.na(final_data_set_to$jury) | !is.na(final_data_set_to$televote),]
		# Ponieważ niektóre kraje (Wielka Brytania) ma kilka obszarów więc w tabelce z wynikami pokazywała się jako duplikat
		final_data_set_to <- unique(as(final_data_set_to, "data.frame"))

		# Pokazanie danych
		final_data_set_to<-final_data_set_to[order(-final_data_set_to$both),]
	})

	output$data_table_given <- renderTable({

		# Wybór danych
		data_set<-get(input$lev)

		# Obliczenie zmiennej both jako sumy głosów telewidzów i jury
		dat_from<-data_set[data_set$ď.żFrom.country == input$country,]
		dat_from$both<-coalesce(dat_from$Jury.Points,0) + coalesce(dat_from$Televote.Points,0)
		dat_from$country<-dat_from$To.country

		# Stworzenie zbioru do pokazania danych
		map$country<-map$sovereignt
		final_data_set_from<-merge(x=map, y=dat_from, by="country", all.x=TRUE)

		# Lista kolumn do pokazania
		cols<-c("country", "jury", "televote", "both")

		# Renamey kolumn
		final_data_set_from$jury<-final_data_set_from$Jury.Points
		final_data_set_from$televote<-final_data_set_from$Televote.Points

		# Wybór obserwacji i kolumn do pokazania
		final_data_set_from <- final_data_set_from[, cols, drop = FALSE]
		final_data_set_from <- final_data_set_from[!is.na(final_data_set_from$jury) | !is.na(final_data_set_from$televote),]
		# Ponieważ niektóre kraje (Wielka Brytania) ma kilka obszarów więc w tabelce z wynikami pokazywała się jako duplikat
		final_data_set_from <- unique(as(final_data_set_from, "data.frame"))

		# Pokazanie danych
		final_data_set_from<-final_data_set_from[order(-final_data_set_from$both),]
	})

	output$data_table_agr <- renderTable({

		# Wybór danych
		data_set<-get(input$lev)

		# Agregacja zmiennych jury i televote po kraju
		jury<-aggregate(data_set$Jury.Points, by=list(Category=data_set$To.country), FUN=sum, na.rm=TRUE, na.action=NULL)
		televote<-aggregate(data_set$Televote.Points, by=list(Category=data_set$To.country), FUN=sum, na.rm=TRUE, na.action=NULL)

		# Renamey kolumn
		jury$jury<-jury$x
		jury$country<-jury$Category
		televote$televote<-televote$x
		televote$country<-televote$Category

		# Obliczenie zmiennej both jako sumy głosów telewidzów i jury
		punkty<-merge(x=jury, y=televote, by="country")
		punkty$both<-coalesce(punkty$jury,0) + coalesce(punkty$televote,0)

		# Stworzenie zbioru do pokazania danych
		map$country<-map$sovereignt
		final_data_set<-merge(x=map, y=punkty, by="country", all.x=TRUE)

		# Lista kolumn do pokazania
		cols<-c("country", "jury", "televote", "both")

		# Wybór obserwacji i kolumn do pokazania
		final_data_set <- final_data_set[, cols, drop = FALSE]
		final_data_set <- final_data_set[!is.na(final_data_set$jury) | !is.na(final_data_set$televote),]
		#cat(typeof(final_data_set))
		# Ponieważ niektóre kraje (Wielka Brytania) ma kilka obszarów więc w tabelce z wynikami pokazywała się jako duplikat
		final_data_set <- unique(as(final_data_set, "data.frame"))

		# Pokazanie danych
		final_data_set<-final_data_set[order(-final_data_set$both),]
	})
})