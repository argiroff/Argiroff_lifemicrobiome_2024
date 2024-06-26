#### Drop ASVs with no sequences ####

drop_0seq_asvs <- function(x) {
  
  tmp1 <- x %>%
    group_by(asv_id) %>%
    mutate(asv_n_seqs = sum(n_seqs)) %>%
    ungroup(.) %>%
    filter(asv_n_seqs > 0) %>%
    select(-asv_n_seqs)
  
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

#### Trim ASVs based on presence/absence ####

trim_asv_pa <- function(x, asv.pa) {
  
  # ASV ID filter
  tmp1 <- x %>%
    mutate(asv_pa = ifelse(n_seqs > 0, 1, 0)) %>%
    group_by(asv_id) %>%
    summarise(asv_total_pa = sum(asv_pa)) %>%
    ungroup() %>%
    filter(asv_total_pa >= asv.pa) %>%
    pull(asv_id)
  
  # Trim
  tmp2 <- x %>%
    filter(asv_id %in% tmp1)
  
  return(tmp2)
  
}

#### Function to get list names for TITAN outputs ####

get_TITAN_list_names <- function(x) {
  
  tmp1 <- x %>%
    str_remove(., "data/processed/") %>%
    str_remove(., "_titan_output.rds") %>%
    str_replace(., "/titan/", "_") %>%
    str_replace(., "/", "_")
  
  return(tmp1)
}

#### Function to format TITAN outputs

format_TITAN_outputs <- function(x) {
  
  # Format table
  tmp1 <- x %>%
    separate(
      col = ID,
      into = c("community", "cutoff", "plant_habitat"),
      sep = "_"
    ) %>%
    
    mutate(
      
      community = ifelse(community == "16S", "Bacteria and Archaea", community),
      community = ifelse(community == "ITS", "Fungi", community),
      
      cutoff = round(as.numeric(cutoff) / 100, 2),
      
      plant_habitat = ifelse(plant_habitat == "BS", "Soil", plant_habitat),
      plant_habitat = ifelse(plant_habitat == "RH", "Rhizosphere", plant_habitat),
      plant_habitat = ifelse(plant_habitat == "RE", "Root endosphere", plant_habitat)
      
    )
  
  return(tmp1)
  
}

#### Standard error ####

se <- function(x) {
  
  tmp1 <- sd(x) / sqrt(length(x))
  
  return(tmp1)
  
}

#### Drop metabolites with concentration of 0 ####

drop_0conc_metab <- function(x) {
  
  tmp1 <- x %>%
    group_by(metabolite_id) %>%
    mutate(metab_concentration = sum(concentration)) %>%
    ungroup(.) %>%
    filter(metab_concentration > 0) %>%
    select(-metab_concentration)
  
  return(tmp1)
  
}

#### Drop samples with no metabolite concentrations ####

drop_0conc_trees <- function(x) {
  
  tmp1 <- x %>%
    group_by(tree_id) %>%
    mutate(tree_concentration = sum(concentration)) %>%
    ungroup(.) %>%
    filter(tree_concentration > 0) %>%
    select(-tree_concentration)
  
  return(tmp1)
  
}

#### Function to format fsumz ####

format_fsumz <- function(x) {
  
  tmp1 <- x %>%
    
    # Format
    mutate(
      
      cutoff = ifelse(str_detect(variable, "f"), cutoff, 0),
      
      variable = ifelse(
        str_detect(variable, "sumz-"),
        "Decreasing",
        "Increasing"
      ),
      
      plant_habitat = factor(
        plant_habitat,
        levels = c("Root endosphere", "Rhizosphere", "Soil")
      ),
      
      variable = factor(
        variable,
        levels = c("Decreasing", "Increasing")
      ),
      
      community = factor(
        community,
        levels = c("Bacteria and Archaea", "Fungi")
      )
    ) %>%
    
    # Mean 0
    group_by(cutoff, community, plant_habitat, site, variable) %>%
    summarise(cp = mean(cp)) %>%
    ungroup(.) %>%
    filter(!is.na(cp)) %>%
    group_by(cutoff, community, plant_habitat, site) %>%
    mutate(n_val = n()) %>%
    ungroup(.) %>%
    filter(n_val == 2) %>%
    select(-n_val)
  
  return(tmp1)
  
}

#### Drop absent features ####

drop_0relabund_features <- function(x) {
  
  tmp1 <- x %>%
    group_by(feature_id) %>%
    mutate(feature_relabund = sum(relabund)) %>%
    ungroup(.) %>%
    filter(feature_relabund > 0) %>%
    select(-feature_relabund)
  
  return(tmp1)
  
}

#### Drop samples with relative abundance ####

drop_0relabund_trees <- function(x) {
  
  tmp1 <- x %>%
    group_by(tree_id) %>%
    mutate(tree_relabund = sum(relabund)) %>%
    ungroup(.) %>%
    filter(tree_relabund > 0) %>%
    select(-tree_relabund)
  
  return(tmp1)
  
}

#### Function to filter features ####

filter_features <- function(feature.tab, feature.prev, sample.cut) {
  
  tmp1 <- feature.tab %>%
    group_by(tree_id) %>%
    mutate(feature_relabund = sum(relabund)) %>%
    ungroup(.)
  
  tmp2 <- length(unique(tmp1$tree_id))
  
  tmp3 <- tmp1 %>%
    mutate(pres_abs = ifelse(relabund > 0, 1, 0)) %>%
    group_by(feature_id) %>%
    summarise(tree_pres = sum(pres_abs)) %>%
    ungroup() %>%
    mutate(prop_tree_pres = tree_pres / tmp2) %>%
    filter(prop_tree_pres >= feature.prev) %>%
    pull(feature_id)
  
  tmp4 <- tmp1 %>%
    filter(feature_id %in% tmp3) %>%
    group_by(tree_id) %>% 
    mutate(remaining_relabund = sum(relabund)) %>% 
    ungroup() %>% 
    filter(remaining_relabund >= sample.cut) %>% 
    select(data_type, plant_habitat, sample_id, tree_id, feature_id, relabund)
  
  return(tmp4)
  
}

#### Function to get tree ID filter ####

get_tree_id_filter <- function(asv.ba, asv.fungi, metab) {
  
  tmp1 <- asv.ba %>%
    select(tree_id) %>%
    distinct(.)
  
  tmp2 <- asv.fungi %>%
    select(tree_id) %>%
    distinct(.)
  
  tmp3 <- metab %>%
    select(tree_id) %>%
    distinct(.) %>%
    inner_join(tmp2, ., by = "tree_id") %>%
    inner_join(tmp1, ., by = "tree_id") %>%
    arrange(tree_id) %>%
    pull(tree_id)
  
  return(tmp3)
  
}

#### Function to get dbRDA scores ####

get_dbRDA_scores <- function(x, env_tab) {
  
  tmp1 <- scores(
    x,
    # Select the first two axes
    choices = c(1, 2),
    # Get plots and ASV scores
    display = "all",
    # Get a nicer output
    tidy = TRUE
  ) %>% 
    
    as_tibble(rownames = NA) %>%
    rownames_to_column(var = "sample_id")
  
  # Get sample loadings
  tmp2 <- tmp1 %>%
    filter(score == "sites") %>%
    select(-label) %>%
    mutate(sample_id = str_replace_all(sample_id, "\\.", "-")) %>%
    inner_join(env_tab, ., by = "sample_id")
  
  # Get variable loadings
  tmp3 <- tmp1 %>%
    filter(score == "biplot") %>% 
    rename(env_variable = "sample_id")
  
  # Get eigenvalues for axis contributions
  tmp4 <- x$CCA$eig / sum(x$CCA$eig)
  tmp5 <- round(100 * tmp4[1], 0)
  tmp6 <- round(100 * tmp4[2], 0)
  
  # Taxa
  tmp7 <- tmp1 %>%
    filter(score == "species")
  
  # Combine
  tmp8 <- list(
    tmp7, tmp2, tmp3, tmp5, tmp6
  ) %>%
    set_names(nm = c("asvs", "loadings", "biplot", "axis1", "axis2"))
  
  # Return
  return(tmp8)
  
}

#### Function to generate dbRDA plots ####

plot_dbRDA <- function(
    dbrda.ord,
    # dbrda.aov,
    plot.title
) {
  
  tmp1 <- ggplot() +
    
    geom_vline(
      xintercept = 0,
      linetype = 2,
      linewidth = 0.5,
      colour = "black"
    ) +
    
    geom_hline(
      yintercept = 0,
      linetype = 2,
      linewidth = 0.5,
      colour = "black"
    ) +
    
    geom_point(
      data = dbrda.ord$loadings,
      aes(x = CAP1, y = CAP2, shape = site, colour = tree_age_site),
      alpha = 0.65
    ) +
    
    scale_shape_manual(
      name = "Stand",
      values = c(16, 15, 17, 18)
    ) +
    
    scale_colour_viridis(
      name = "Tree age",
      option = "plasma"
    ) +
    
    # geom_text(
    #   data = dbrda.aov,
    #   aes(x = xpos, y = ypos, label = sig_label),
    #   parse = TRUE,
    #   size = 3
    # ) +
    
    labs(
      title = plot.title, 
      x = bquote('Axis 1 (' * .(dbrda.ord$axis1) * '%)'),
      y = bquote('Axis 2 (' * .(dbrda.ord$axis2) * '%)')
    ) + 
    
    theme(
      
      # Panel
      panel.border = element_rect(colour = "black", fill = NA, linewidth = 1),
      panel.background = element_blank(),
      panel.grid = element_blank(),
      
      # Titles
      plot.title = element_text(colour = "black", size = 14, hjust = 0, face = "bold"),
      axis.title = element_text(colour = "black", size = 12),
      
      # Axis
      axis.ticks = element_line(colour = "black", linewidth = 0.25),
      axis.text = element_text(colour = "black", size = 10),
      
      # Legend
      legend.key = element_blank(), 
      legend.background = element_blank(),
      legend.title = element_text(colour = "black", size = 10), 
      legend.text = element_text(colour = "black", size = 8),
      legend.position = "bottom"
      
    )
  
  return(tmp1)
  
}

#### Function to format dbRDA ANOVAs ####

format_dbRDA_aov <- function(x) {
  
  aov_results <- x %>%
    select(variable, `Pr(>F)`) %>%
    filter(variable != "Residual") %>%
    
    mutate(
      
      variable = ifelse(
        variable == "tree_age_site",
        "Age",
        variable
      ),
      
      variable = ifelse(
        variable == "site",
        "Stand",
        variable
      ),
      
      variable = ifelse(
        variable == "tree_age_site:site",
        "Age%*%stand",
        variable
      ),
      
      `Pr(>F)` = ifelse(
        `Pr(>F)` == 0.001,
        "italic(P)<0.001",
        paste("italic(P)=", `Pr(>F)`, sep = "")
      )
      
    ) %>%
    
    # Combine
    unite(sig_label, variable, `Pr(>F)`, sep = "~") %>%
    pull(sig_label)
  
  # Add new lines
  aov_out <- tibble(
    sig_label = paste(aov_results, collapse = "\n")
  )
  
  return(aov_out)
  
}
