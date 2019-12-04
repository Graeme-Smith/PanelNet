#
# Purpose: Interactive Shiny App that allows the user to select multiple PanelApp panels using the 
# PanelApp API.  Network analysis is then performed to identify 
source("chooser.R")
library(shiny)
library(tidyverse)
library(jsonlite)
library(ggplot2)
library(plotly)
library(WebGestaltR)

# Define functions

getPanelAppList <- function() {
  api_query <- "https://panelapp.genomicsengland.co.uk/WebServices/list_panels/?format=json"
  json_data <- fromJSON(api_query, flatten=TRUE)
  panelApp_panels <- tibble(panel_name = json_data$result$Name,
                            panel_id = json_data$result$Panel_Id,
                            num_of_gene = json_data$result$Number_of_Genes,
                            version = json_data$result$CurrentVersion
                            )
  return(panelApp_panels)
}

panel_list <- getPanelAppList()

getPanelGenes <- function(panel_id){
  api_query <- paste0("https://panelapp.genomicsengland.co.uk/WebServices/get_panel/",
                      panel_id,
                      "/?format=json")
  json_data <- fromJSON(api_query, flatten=TRUE)
  panel_genes <- json_data$result$Genes$GeneSymbol
  return(panel_genes)
}

ui <- navbarPage(
  "PanelApp Pathway Analysis",
  tabPanel(
    "Select Panels",
    titlePanel("Select Panels"),
    chooserInput(
      "mychooser",
      "Available PanelApp Panels",
      "Selected PanelApp Panels",
      panel_list$panel_name,
      c(),
      size = 10,
      multiple = TRUE
    ),
    actionButton("runAll", label="Run Analysis"),
    p("Click the button to analyze panels")
  ),
  tabPanel("Available PanelApp Panels",
           titlePanel("Available Panels"),
           DT::dataTableOutput("panel_table")
  ),
  tabPanel("Imported genes",
           titlePanel("Genes Selected for Analysis"),
           DT::dataTableOutput("gene_table")
  ),
  tabPanel("Network Analysis",
           "Place html help file here"
  ),
  tabPanel("Help",
           "Place html help file here"
  )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  # Render selected panel
  output$selection <- renderPrint({
    input$mychooser[1]
  })
  
  # Display selected genes in table
  output$panel_table <- DT::renderDataTable({
    # DT::datatable(RV$data[seq_df$genus %in% unlist(input$mychooser[2]),])
    DT::datatable(as.data.frame(panel_list))
  })

  # Display selected genes in table
  output$gene_table <- DT::renderDataTable({
    # DT::datatable(RV$data[seq_df$genus %in% unlist(input$mychooser[2]),])
    # loop through all selected gene panels
    #for(panel in input$mychooser[1]){
      
    #}
    DT::datatable(as.data.frame(input$mychooser[2]))
  })  
    
}

# Run the application 
shinyApp(ui = ui, server = server)
