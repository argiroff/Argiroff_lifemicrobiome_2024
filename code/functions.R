#### Drop OTUs with no sequences ####

drop_0seq_otus <- function(x) {
  
  tmp1 <- x %>%
    group_by(otu_id) %>%
    mutate(otu_n_seqs = sum(n_seqs)) %>%
    ungroup(.) %>%
    filter(otu_n_seqs > 0) %>%
    select(-otu_n_seqs)
  
  return(tmp1)
  
}

#### Drop samples with no sequences ####

drop_0seq_samples <- function(x) {
  
  tmp1 <- x %>%
    group_by(sample_id) %>%
    mutate(sample_n_seqs = sum(n_seqs)) %>%
    ungroup(.) %>%
    filter(sample_n_seqs > 0) %>%
    select(-sample_n_seqs)
  
  return(tmp1)
  
}

#### Read metadata ####

read_metadata <- function(x) {
  
  tmp1 <- read_tsv(x, col_types = cols(root_dist = col_double()))
  
  return(tmp1)
  
}

#### Function to get facet titles ####

get_facet_title <- function(community, plant_habitat) {
  
  if(community == "Bacteria and Archaea" & plant_habitat == "Root endosphere") {
    
    tmp1 = "(a)"
    
  } else if(community == "Bacteria and Archaea" & plant_habitat == "Rhizosphere") {
    
    tmp1 = "(c)"
    
  } else if(community == "Bacteria and Archaea" & plant_habitat == "Soil") {
    
    tmp1 = "(e)"
    
  } else if(community == "Fungi" & plant_habitat == "Root endosphere") {
    
    tmp1 = "(b)"
    
  } else if(community == "Fungi" & plant_habitat == "Rhizosphere") {
    
    tmp1 = "(d)"
    
  } else if(community == "Fungi" & plant_habitat == "Soil") {
    
    tmp1 = "(f)"
    
  }
  
  return(tmp1)
  
}

#### Function to format axis labels

format_axis <- function(x) {
  
  tmp1 <- format(x, big.mark = ",", scientific = FALSE)
  
  return(tmp1)
  
}
