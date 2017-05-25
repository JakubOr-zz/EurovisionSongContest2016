library(shiny)

shinyUI(
	fluidPage(
	titlePanel("Eurovision 2016 results"),

		sidebarLayout(
			position = "right",
			sidebarPanel(
				shinyUI(
					fluidPage(
						fluidRow(
							column(
								7, 
								# Wybór pomiędzy półfinałami i finałem
								radioButtons("lev", label = h3("Tournament"),
								choices = list(
												"1st Semifinal 2016"="sf1_2016",
												"2nd Semifinal 2016"="sf2_2016",
												"Final 2016"="gf_2016"
											),
												selected = "gf_2016"
											),
								# Wybór kraju w zależności od tego jaki turniej został wybrany
								uiOutput("choose_country")
							)
						)
					)
				)
			),
			mainPanel(
				br(),
				# Panel pokazujący się gdy nie został wybrany żaden kraj
				# Pokazuje wykres z wynikami wszystkich krajów
				# Oraz tabelkę z punktami zdobytymi
				conditionalPanel(
					condition = "input.country == 'all'",

					plotOutput("Plot_All"),

					tableOutput("data_table_agr")
				),
				# Panel pokazujący wyniki dla jednego kraju
				# Pokazuje wyniki uzyskane przez kraj (GAINED) na mapie wraz z tabelką
				# Oraz głosy oddane przez kraj (GIVEN)
				conditionalPanel(
					condition = "input.country != 'all'",

					titlePanel("Gained"),

					br(),

					plotOutput("Plot_Gained"),

					tableOutput("data_table_gained"),

					titlePanel("Given"),

					br(),

					plotOutput("Plot_Given"),

					tableOutput("data_table_given")
				)
			)
		)
	)
)