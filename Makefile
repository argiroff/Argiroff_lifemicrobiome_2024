.SECONDARY:
.SECONDEXPANSION:
print-% :
	@echo '$*=$($*)'

# Rule
# target : prerequisite1 prerequisite2 prerequisite3
# (tab)recipe (and other arguments that are passed to the BASH[or other] script)

#### Use R to make QIIME2 manifest files ####

# 16S
PATH_16S=$(wildcard data/qiime2/16S/*)
MANIFEST_16S_OUT=$(foreach path,$(PATH_16S),$(path)/manifest.txt)

$(MANIFEST_16S_OUT) : code/get_manifest.R\
		$$(dir $$@)reads/
	code/get_manifest.R $(dir $@)reads/ $@

# ITS
PATH_ITS=$(wildcard data/qiime2/ITS/*)
MANIFEST_ITS_OUT=$(foreach path,$(PATH_ITS),$(path)/manifest.txt)

$(MANIFEST_ITS_OUT) : code/get_manifest.R\
		$$(dir $$@)reads/
	code/get_manifest.R $(dir $@)reads/ $@

#### IMPORT fastq to qza using QIIME2 ####

# 16S
IMPORT_16S_OUT=$(foreach path,$(PATH_16S),$(path)/demux.qza)

$(IMPORT_16S_OUT) : code/import_seqs_to_qza.sh\
		$$(dir $$@)manifest.txt
	code/import_seqs_to_qza.sh $(dir $@)manifest.txt

# ITS
IMPORT_ITS_OUT=$(foreach path,$(PATH_ITS),$(path)/demux.qza)

$(IMPORT_ITS_OUT) : code/import_seqs_to_qza.sh\
		$$(dir $$@)manifest.txt
	code/import_seqs_to_qza.sh $(dir $@)manifest.txt

IMPORT_ITS=$(MANIFEST_ITS_OUT) $(IMPORT_ITS_OUT)

#### Summarize imported raw seqs as qzv ####

# 16S
SUM_16S_OUT=$(foreach path,$(PATH_16S),$(path)/demux_summary.qzv)

$(SUM_16S_OUT) : code/summarize_seqs.sh\
		$$(dir $$@)demux.qza
	code/summarize_seqs.sh $(dir $@)demux.qza

# ITS
SUM_ITS_OUT=$(foreach path,$(PATH_ITS),$(path)/demux_summary.qzv)

$(SUM_ITS_OUT) : code/summarize_seqs.sh\
		$$(dir $$@)demux.qza
	code/summarize_seqs.sh $(dir $@)demux.qza

#### Trim sequences ####

# 16S, cutadapt
TRIM_16S_OUT=$(foreach path,$(PATH_16S),$(path)/trimmed.qza)

$(TRIM_16S_OUT) : code/cutadapt_16s.sh\
		$$(dir $$@)demux.qza
	code/cutadapt_16s.sh $(dir $@)demux.qza

# ITS, ITSxpress
TRIM_ITS_OUT=$(foreach path,$(PATH_ITS),$(path)/trimmed.qza)

$(TRIM_ITS_OUT) : code/itsxpress_its.sh\
		$$(dir $$@)demux.qza
	code/itsxpress_its.sh $(dir $@)demux.qza

#### Summarize trimmed seqs as qzv ####

# 16S
SUM_16S_TRIM=$(foreach path,$(PATH_16S),$(path)/trimmed_summary.qzv)

$(SUM_16S_TRIM) : code/summarize_trimmed_seqs.sh\
		$$(dir $$@)trimmed.qza
	code/summarize_trimmed_seqs.sh $(dir $@)trimmed.qza

# ITS
SUM_ITS_TRIM=$(foreach path,$(PATH_ITS),$(path)/trimmed_summary.qzv)

$(SUM_ITS_TRIM) : code/summarize_trimmed_seqs.sh\
		$$(dir $$@)trimmed.qza
	code/summarize_trimmed_seqs.sh $(dir $@)trimmed.qza

#### DADA2

# 16S
DADA2_16S=$(foreach path,$(PATH_16S),$(path)/dada2/)

$(DADA2_16S) : code/dada2.sh\
		$$(subst dada2,trimmed.qza,$$@)
	code/dada2.sh $(subst dada2,trimmed.qza,$@)

# ITS
DADA2_ITS=$(foreach path,$(PATH_ITS),$(path)/dada2/)

$(DADA2_ITS) : code/dada2.sh\
		$$(subst dada2,trimmed.qza,$$@)
	code/dada2.sh $(subst dada2,trimmed.qza,$@)

#### Summarize DADA2 output as qzv ####

# 16S
SUM_16S_DADA2=$(foreach path,$(PATH_16S),$(path)/denoising_stats_summary.qzv)

$(SUM_16S_DADA2) : code/summarize_dada2.sh\
		$$(dir $$@)dada2/denoising_stats.qza
	code/summarize_dada2.sh $(dir $@)dada2/denoising_stats.qza

# ITS
SUM_ITS_DADA2=$(foreach path,$(PATH_ITS),$(path)/denoising_stats_summary.qzv)

$(SUM_ITS_DADA2) : code/summarize_dada2.sh\
		$$(dir $$@)dada2/denoising_stats.qza
	code/summarize_dada2.sh $(dir $@)dada2/denoising_stats.qza

#### Merge ASV tables ####

# 16S
TAB_16S=$(wildcard data/qiime2/16S/*/dada2/table.qza)
MERGE_TAB_16S=data/qiime2/final_qzas/16S/merged_table.qza

$(MERGE_TAB_16S) : code/merge_tables.sh\
		$$(TAB_16S)
	code/merge_tables.sh $(TAB_16S)

#ITS
TAB_ITS=$(wildcard data/qiime2/ITS/*/dada2/table.qza)
MERGE_TAB_ITS=data/qiime2/final_qzas/ITS/merged_table.qza

$(MERGE_TAB_ITS) : code/merge_tables.sh\
		$$(TAB_ITS)
	code/merge_tables.sh $(TAB_ITS)

#### Merge ASV representative sequences ####

# 16S
SEQS_16S=$(wildcard data/qiime2/16S/*/dada2/representative_sequences.qza)
MERGE_SEQS_16S=data/qiime2/final_qzas/16S/merged_representative_sequences.qza

$(MERGE_SEQS_16S) : code/merge_repseqs.sh\
		$$(SEQS_16S)
	code/merge_repseqs.sh $(SEQS_16S)

#ITS
SEQS_ITS=$(wildcard data/qiime2/ITS/*/dada2/representative_sequences.qza)
MERGE_SEQS_ITS=data/qiime2/final_qzas/ITS/merged_representative_sequences.qza

$(MERGE_SEQS_ITS) : code/merge_repseqs.sh\
		$$(SEQS_ITS)
	code/merge_repseqs.sh $(SEQS_ITS)

#### Cluster 97% OTUs, table ####

# 16S
OTU_97_16S=data/qiime2/final_qzas/16S/otu_97/

$(OTU_97_16S) : code/cluster_otu_97.sh\
		data/qiime2/final_qzas/16S/merged_table.qza\
		data/qiime2/final_qzas/16S/merged_representative_sequences.qza
	code/cluster_otu_97.sh data/qiime2/final_qzas/16S/merged_table.qza data/qiime2/final_qzas/16S/merged_representative_sequences.qza

#ITS
OTU_97_ITS=data/qiime2/final_qzas/ITS/otu_97/

$(OTU_97_ITS) : code/cluster_otu_97.sh\
		data/qiime2/final_qzas/ITS/merged_table.qza\
		data/qiime2/final_qzas/ITS/merged_representative_sequences.qza
	code/cluster_otu_97.sh data/qiime2/final_qzas/ITS/merged_table.qza data/qiime2/final_qzas/ITS/merged_representative_sequences.qza

#### Assign taxonomy ####

# 16S
TAX_16S=data/qiime2/final_qzas/16S/otu_97_taxonomy/

$(TAX_16S) : code/assign_tax_16s.sh\
		data/qiime2/final_qzas/16S/otu_97/clustered_sequences.qza\
		data/qiime2/final_qzas/taxonomy/16S/silva-138-99-515-806-nb-classifier.qza
	code/assign_tax_16s.sh data/qiime2/final_qzas/16S/otu_97/clustered_sequences.qza data/qiime2/final_qzas/taxonomy/16S/silva-138-99-515-806-nb-classifier.qza

# ITS
TAX_ITS=data/qiime2/final_qzas/ITS/otu_97_taxonomy/

$(TAX_ITS) : code/assign_tax_its.sh\
		data/qiime2/final_qzas/ITS/otu_97/clustered_sequences.qza\
		data/qiime2/final_qzas/taxonomy/ITS/unite_train/unite_QZAs/unite_ver9_seqs_dynamic_29112022.qza\
		data/qiime2/final_qzas/taxonomy/ITS/unite_train/unite_QZAs/unite_ver9_taxonomy_dynamic_29112022.qza
	code/assign_tax_its.sh data/qiime2/final_qzas/ITS/otu_97/clustered_sequences.qza data/qiime2/final_qzas/taxonomy/ITS/unite_train/unite_QZAs/unite_ver9_seqs_dynamic_29112022.qza data/qiime2/final_qzas/taxonomy/ITS/unite_train/unite_QZAs/unite_ver9_taxonomy_dynamic_29112022.qza

#### Full QIIME2 rules ####

# 16S

qiime2_16s : $(MANIFEST_16S_OUT) $(IMPORT_16S_OUT) $(SUM_16S_OUT)\
	$(TRIM_16S_OUT) $(SUM_16S_TRIM) $(DADA2_16S) $(SUM_16S_DADA2)\
	$(MERGE_TAB_16S) $(MERGE_SEQS_16S) $(OTU_97_16S) $(TAX_16S)

# ITS
qiime2_its : $(MANIFEST_ITS_OUT) $(IMPORT_ITS_OUT) $(SUM_ITS_OUT)\
	$(TRIM_ITS_OUT) $(SUM_ITS_TRIM) $(DADA2_ITS) $(SUM_ITS_DADA2)\
	$(MERGE_TAB_ITS) $(MERGE_SEQS_ITS) $(OTU_97_ITS) $(TAX_ITS)

#### Format sequence metadata ####

# 16S, BC
METADATA_16S=data/processed/16S/metadata_working/metadata_16s.txt

$(METADATA_16S) : code/format_metadata.R\
		$$(MANIFEST_16S_OUT)\
		data/metadata/tree_age.txt
	code/format_metadata.R $(MANIFEST_16S_OUT) data/metadata/tree_age.txt $@

# ITS, BC
METADATA_ITS=data/processed/ITS/metadata_working/metadata_its.txt

$(METADATA_ITS) : code/format_metadata.R\
		$$(MANIFEST_ITS_OUT)\
		data/metadata/tree_age.txt
	code/format_metadata.R $(MANIFEST_ITS_OUT) data/metadata/tree_age.txt $@

#### Metabolites ####

METAB=data/processed/environ/root_metabolites.txt

$(METAB) : code/format_metabolites.R\
		data/environ/root_metabolites_raw.txt
	code/format_metabolites.R data/environ/root_metabolites_raw.txt $@

#### Tree age ####

# Full dataset
TREE_AGE=data/processed/environ/tree_age_full.rds

$(TREE_AGE) : code/tree_age.R\
		$$(METAB)\
		data/metadata/tree_age.txt
	code/tree_age.R $(METAB) data/metadata/tree_age.txt $@

# Site-specific
TREE_AGE_SITE=data/processed/environ/tree_age_site.rds

$(TREE_AGE_SITE) : code/tree_age_site.R\
		$$(METAB)\
		data/metadata/tree_age.txt\
		$$(TREE_AGE)
	code/tree_age_site.R $(METAB) data/metadata/tree_age.txt $(TREE_AGE) $@

#### Final phyloseq objects ####

# 16S, phyloseq untrimmed
PS_16S_UNTRIMMED=data/processed/16S/otu_processed/ps_untrimmed.rds

$(PS_16S_UNTRIMMED) : code/make_ps_untrimmed.R\
		$$(wildcard $$(OTU_97_16S)*.qza)\
		$$(wildcard $$(TAX_16S)*.qza)\
		$$(METADATA_16S)\
		$$(METAB)
	code/make_ps_untrimmed.R $(wildcard $(OTU_97_16S)*.qza) $(wildcard $(TAX_16S)*.qza) $(METADATA_16S) $(METAB) $@

# 16S, phyloseq trimmed
PS_16S_TRIMMED=data/processed/16S/otu_processed/ps_trimmed.rds

$(PS_16S_TRIMMED) : code/make_16s_ps_trimmed.R\
		$$(PS_16S_UNTRIMMED)
	code/make_16s_ps_trimmed.R $(PS_16S_UNTRIMMED) $@

# ITS, phyloseq untrimmed
PS_ITS_UNTRIMMED=data/processed/ITS/otu_processed/ps_untrimmed.rds

$(PS_ITS_UNTRIMMED) : code/make_ps_untrimmed.R\
		$$(wildcard $$(OTU_97_ITS)*.qza)\
		data/qiime2/final_qzas/ITS/otu_97_taxonomy/classification.qza\
		$$(METADATA_ITS)\
		$$(METAB)
	code/make_ps_untrimmed.R $(wildcard $(OTU_97_ITS)*.qza) data/qiime2/final_qzas/ITS/otu_97_taxonomy/classification.qza $(METADATA_ITS) $(METAB) $@

# ITS, phyloseq trimmed
PS_ITS_TRIMMED=data/processed/ITS/otu_processed/ps_trimmed.rds

$(PS_ITS_TRIMMED) : code/make_ITs_ps_trimmed.R\
		$$(PS_ITS_UNTRIMMED)
	code/make_its_ps_trimmed.R $(PS_ITS_UNTRIMMED) $@

#### Final OTU tibbles ####

# 16S, OTU
FINAL_16S_OTU=data/processed/16S/otu_processed/otu_table.txt

$(FINAL_16S_OTU) : code/get_otu_tibble.R\
		$$(PS_16S_TRIMMED)
	code/get_otu_tibble.R $(PS_16S_TRIMMED) $@

# ITS, OTU
FINAL_ITS_OTU=data/processed/ITS/otu_processed/otu_table.txt

$(FINAL_ITS_OTU) : code/get_otu_tibble.R\
		$$(PS_ITS_TRIMMED)
	code/get_otu_tibble.R $(PS_ITS_TRIMMED) $@

#### Final metadata tibbles ####

# 16S, metadata
FINAL_16S_META=data/processed/16S/otu_processed/metadata_table.txt

$(FINAL_16S_META) : code/get_metadata_tibble.R\
		$$(PS_16S_TRIMMED)
	code/get_metadata_tibble.R $(PS_16S_TRIMMED) $@

# ITS, metadata
FINAL_ITS_META=data/processed/ITS/otu_processed/metadata_table.txt

$(FINAL_ITS_META) : code/get_metadata_tibble.R\
		$$(PS_ITS_TRIMMED)
	code/get_metadata_tibble.R $(PS_ITS_TRIMMED) $@

#### Final representative sequence fasta ####

# 16S, representative sequences
FINAL_16S_REPSEQS=data/processed/16S/otu_processed/representative_sequences.fasta

$(FINAL_16S_REPSEQS) : code/get_repseqs_fasta.R\
		$$(PS_16S_TRIMMED)
	code/get_repseqs_fasta.R $(PS_16S_TRIMMED) $@

# ITS, representative sequences
FINAL_ITS_REPSEQS=data/processed/ITS/otu_processed/representative_sequences.fasta

$(FINAL_ITS_REPSEQS) : code/get_repseqs_fasta.R\
		$$(PS_ITS_TRIMMED)
	code/get_repseqs_fasta.R $(PS_ITS_TRIMMED) $@

#### Final taxonomy tibbles ####

# 16S, taxonomy
FINAL_16S_TAX=data/processed/16S/otu_processed/taxonomy_table.txt

$(FINAL_16S_TAX) : code/get_taxonomy_tibble.R\
		$$(PS_16S_TRIMMED)\
	code/get_taxonomy_tibble.R $(PS_16S_TRIMMED) $@

# ITS, taxonomy
FINAL_ITS_TAX=data/processed/ITS/otu_processed/taxonomy_table.txt

$(FINAL_ITS_TAX) : code/get_taxonomy_tibble.R\
		$$(PS_ITS_TRIMMED)
	code/get_taxonomy_tibble.R $(PS_ITS_TRIMMED) $@

#### Final sequence summary tibbles ####

# 16S sequence summary
FINAL_16S_SUM=data/processed/16S/otu_processed/sequence_summary.txt

$(FINAL_16S_SUM) : code/get_seq_summary_tibble.R\
		$$(PS_16S_UNTRIMMED)\
		$$(PS_16S_TRIMMED)
	code/get_seq_summary_tibble.R $(PS_16S_UNTRIMMED) $(PS_16S_TRIMMED) $@

# ITS sequence summary
FINAL_ITS_SUM=data/processed/ITS/otu_processed/sequence_summary.txt

$(FINAL_ITS_SUM) : code/get_seq_summary_tibble.R\
		$$(PS_ITS_UNTRIMMED)\
		$$(PS_ITS_TRIMMED)
	code/get_seq_summary_tibble.R $(PS_ITS_UNTRIMMED) $(PS_ITS_TRIMMED) $@


otu : $(METADATA_16S) $(METADATA_ITS) $(METAB) $(TREE_AGE)\
$(TREE_AGE_SITE) $(PS_16S_UNTRIMMED) $(PS_16S_TRIMMED) $(PS_ITS_UNTRIMMED)\
$(PS_ITS_TRIMMED) $(FINAL_16S_OTU) $(FINAL_ITS_OTU) $(FINAL_16S_META)\
$(FINAL_ITS_META) $(FINAL_16S_REPSEQS) $(FINAL_ITS_REPSEQS) $(FINAL_16S_TAX)\
$(FINAL_ITS_TAX) $(FINAL_16S_SUM) $(FINAL_ITS_SUM)
