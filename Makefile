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

# #### Cluster 97% OTUs, table ####

# # 16S
# OTU_97_16S=data/qiime2/final_qzas/16S/otu_97/

# $(OTU_97_16S) : code/cluster_otu_97.sh\
# 		data/qiime2/final_qzas/16S/merged_table.qza\
# 		data/qiime2/final_qzas/16S/merged_representative_sequences.qza
# 	code/cluster_otu_97.sh data/qiime2/final_qzas/16S/merged_table.qza data/qiime2/final_qzas/16S/merged_representative_sequences.qza

# #ITS
# OTU_97_ITS=data/qiime2/final_qzas/ITS/otu_97/

# $(OTU_97_ITS) : code/cluster_otu_97.sh\
# 		data/qiime2/final_qzas/ITS/merged_table.qza\
# 		data/qiime2/final_qzas/ITS/merged_representative_sequences.qza
# 	code/cluster_otu_97.sh data/qiime2/final_qzas/ITS/merged_table.qza data/qiime2/final_qzas/ITS/merged_representative_sequences.qza

#### Assign taxonomy ####

# # 16S
# TAX_16S=data/qiime2/final_qzas/16S/otu_97_taxonomy/

# $(TAX_16S) : code/assign_tax_16s.sh\
# 		data/qiime2/final_qzas/16S/otu_97/clustered_sequences.qza\
# 		data/qiime2/final_qzas/taxonomy/16S/silva-138-99-515-806-nb-classifier.qza
# 	code/assign_tax_16s.sh data/qiime2/final_qzas/16S/otu_97/clustered_sequences.qza data/qiime2/final_qzas/taxonomy/16S/silva-138-99-515-806-nb-classifier.qza

# # ITS
# TAX_ITS=data/qiime2/final_qzas/ITS/otu_97_taxonomy/

# $(TAX_ITS) : code/assign_tax_its.sh\
# 		data/qiime2/final_qzas/ITS/otu_97/clustered_sequences.qza\
# 		data/qiime2/final_qzas/taxonomy/ITS/unite_train/unite_QZAs/unite_ver9_seqs_dynamic_29112022.qza\
# 		data/qiime2/final_qzas/taxonomy/ITS/unite_train/unite_QZAs/unite_ver9_taxonomy_dynamic_29112022.qza
# 	code/assign_tax_its.sh data/qiime2/final_qzas/ITS/otu_97/clustered_sequences.qza data/qiime2/final_qzas/taxonomy/ITS/unite_train/unite_QZAs/unite_ver9_seqs_dynamic_29112022.qza data/qiime2/final_qzas/taxonomy/ITS/unite_train/unite_QZAs/unite_ver9_taxonomy_dynamic_29112022.qza

# 16S
TAX_16S=data/qiime2/final_qzas/16S/asv_taxonomy/

$(TAX_16S) : code/assign_tax_16s_asv.sh\
		data/qiime2/final_qzas/16S/merged_representative_sequences.qza\
		data/qiime2/final_qzas/taxonomy/16S/silva-138-99-515-806-nb-classifier.qza
	code/assign_tax_16s_asv.sh data/qiime2/final_qzas/16S/merged_representative_sequences.qza data/qiime2/final_qzas/taxonomy/16S/silva-138-99-515-806-nb-classifier.qza

# ITS
TAX_ITS=data/qiime2/final_qzas/ITS/asv_taxonomy/

$(TAX_ITS) : code/assign_tax_its_asv.sh\
		data/qiime2/final_qzas/ITS/merged_representative_sequences.qza\
		data/qiime2/final_qzas/taxonomy/ITS/unite_train/unite_QZAs/unite_ver9_seqs_dynamic_29112022.qza\
		data/qiime2/final_qzas/taxonomy/ITS/unite_train/unite_QZAs/unite_ver9_taxonomy_dynamic_29112022.qza
	code/assign_tax_its_asv.sh data/qiime2/final_qzas/ITS/merged_representative_sequences.qza data/qiime2/final_qzas/taxonomy/ITS/unite_train/unite_QZAs/unite_ver9_seqs_dynamic_29112022.qza data/qiime2/final_qzas/taxonomy/ITS/unite_train/unite_QZAs/unite_ver9_taxonomy_dynamic_29112022.qza

#### Full QIIME2 rules ####

# 16S
# qiime2_16s : $(MANIFEST_16S_OUT) $(IMPORT_16S_OUT) $(SUM_16S_OUT)\
# 	$(TRIM_16S_OUT) $(SUM_16S_TRIM) $(DADA2_16S) $(SUM_16S_DADA2)\
# 	$(MERGE_TAB_16S) $(MERGE_SEQS_16S) $(OTU_97_16S) $(TAX_16S)

qiime2_16s : $(MANIFEST_16S_OUT) $(IMPORT_16S_OUT) $(SUM_16S_OUT)\
	$(TRIM_16S_OUT) $(SUM_16S_TRIM) $(DADA2_16S) $(SUM_16S_DADA2)\
	$(MERGE_TAB_16S) $(MERGE_SEQS_16S) $(TAX_16S)

# ITS
# qiime2_its : $(MANIFEST_ITS_OUT) $(IMPORT_ITS_OUT) $(SUM_ITS_OUT)\
# 	$(TRIM_ITS_OUT) $(SUM_ITS_TRIM) $(DADA2_ITS) $(SUM_ITS_DADA2)\
# 	$(MERGE_TAB_ITS) $(MERGE_SEQS_ITS) $(OTU_97_ITS) $(TAX_ITS)

qiime2_its : $(MANIFEST_ITS_OUT) $(IMPORT_ITS_OUT) $(SUM_ITS_OUT)\
	$(TRIM_ITS_OUT) $(SUM_ITS_TRIM) $(DADA2_ITS) $(SUM_ITS_DADA2)\
	$(MERGE_TAB_ITS) $(MERGE_SEQS_ITS) $(TAX_ITS)

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
PS_16S_UNTRIMMED=data/processed/16S/asv_processed/ps_untrimmed.rds

$(PS_16S_UNTRIMMED) : code/make_ps_untrimmed.R\
		$$(wildcard data/qiime2/final_qzas/16S/*.qza)\
		$$(wildcard $$(TAX_16S)*.qza)\
		$$(METADATA_16S)\
		$$(METAB)
	code/make_ps_untrimmed.R $(wildcard data/qiime2/final_qzas/16S/*.qza) $(wildcard $(TAX_16S)*.qza) $(METADATA_16S) $(METAB) $@

# 16S, phyloseq trimmed
PS_16S_TRIMMED=data/processed/16S/asv_processed/ps_trimmed.rds

$(PS_16S_TRIMMED) : code/make_16s_ps_trimmed.R\
		$$(PS_16S_UNTRIMMED)
	code/make_16s_ps_trimmed.R $(PS_16S_UNTRIMMED) $@

# ITS, phyloseq untrimmed
PS_ITS_UNTRIMMED=data/processed/ITS/asv_processed/ps_untrimmed.rds

$(PS_ITS_UNTRIMMED) : code/make_ps_untrimmed.R\
		$$(wildcard data/qiime2/final_qzas/ITS/*.qza)\
		data/qiime2/final_qzas/ITS/asv_taxonomy/classification.qza\
		$$(METADATA_ITS)\
		$$(METAB)
	code/make_ps_untrimmed.R data/qiime2/final_qzas/ITS/*.qza data/qiime2/final_qzas/ITS/asv_taxonomy/classification.qza $(METADATA_ITS) $(METAB) $@

# ITS, phyloseq trimmed
PS_ITS_TRIMMED=data/processed/ITS/asv_processed/ps_trimmed.rds

$(PS_ITS_TRIMMED) : code/make_its_ps_trimmed.R\
		$$(PS_ITS_UNTRIMMED)
	code/make_its_ps_trimmed.R $(PS_ITS_UNTRIMMED) $@

#### Final ASV tibbles ####

# 16S, ASV
FINAL_16S_ASV=data/processed/16S/asv_processed/asv_table.txt

$(FINAL_16S_ASV) : code/get_asv_tibble.R\
		$$(PS_16S_TRIMMED)
	code/get_asv_tibble.R $(PS_16S_TRIMMED) $@

# ITS, ASV
FINAL_ITS_ASV=data/processed/ITS/asv_processed/asv_table.txt

$(FINAL_ITS_ASV) : code/get_asv_tibble.R\
		$$(PS_ITS_TRIMMED)
	code/get_asv_tibble.R $(PS_ITS_TRIMMED) $@

#### Final metadata tibbles ####

# 16S, metadata
FINAL_16S_META=data/processed/16S/asv_processed/metadata_table.txt

$(FINAL_16S_META) : code/get_metadata_tibble.R\
		$$(PS_16S_TRIMMED)
	code/get_metadata_tibble.R $(PS_16S_TRIMMED) $@

# ITS, metadata
FINAL_ITS_META=data/processed/ITS/asv_processed/metadata_table.txt

$(FINAL_ITS_META) : code/get_metadata_tibble.R\
		$$(PS_ITS_TRIMMED)
	code/get_metadata_tibble.R $(PS_ITS_TRIMMED) $@

#### Final representative sequence fasta ####

# 16S, representative sequences
FINAL_16S_REPSEQS=data/processed/16S/asv_processed/representative_sequences.fasta

$(FINAL_16S_REPSEQS) : code/get_repseqs_fasta.R\
		$$(PS_16S_TRIMMED)
	code/get_repseqs_fasta.R $(PS_16S_TRIMMED) $@

# ITS, representative sequences
FINAL_ITS_REPSEQS=data/processed/ITS/asv_processed/representative_sequences.fasta

$(FINAL_ITS_REPSEQS) : code/get_repseqs_fasta.R\
		$$(PS_ITS_TRIMMED)
	code/get_repseqs_fasta.R $(PS_ITS_TRIMMED) $@

#### Final taxonomy tibbles ####

# 16S, taxonomy
FINAL_16S_TAX=data/processed/16S/asv_processed/taxonomy_table.txt

$(FINAL_16S_TAX) : code/get_taxonomy_tibble.R\
		$$(PS_16S_TRIMMED)
	code/get_taxonomy_tibble.R $(PS_16S_TRIMMED) $@

# ITS, taxonomy
FINAL_ITS_TAX=data/processed/ITS/asv_processed/taxonomy_table.txt

$(FINAL_ITS_TAX) : code/get_taxonomy_tibble.R\
		$$(PS_ITS_TRIMMED)
	code/get_taxonomy_tibble.R $(PS_ITS_TRIMMED) $@

#### Final sequence summary tibbles ####

# 16S sequence summary
FINAL_16S_SUM=data/processed/16S/asv_processed/sequence_summary.txt

$(FINAL_16S_SUM) : code/get_seq_summary_tibble.R\
		$$(PS_16S_UNTRIMMED)\
		$$(PS_16S_TRIMMED)
	code/get_seq_summary_tibble.R $(PS_16S_UNTRIMMED) $(PS_16S_TRIMMED) $@

# ITS sequence summary
FINAL_ITS_SUM=data/processed/ITS/asv_processed/sequence_summary.txt

$(FINAL_ITS_SUM) : code/get_seq_summary_tibble.R\
		$$(PS_ITS_UNTRIMMED)\
		$$(PS_ITS_TRIMMED)
	code/get_seq_summary_tibble.R $(PS_ITS_UNTRIMMED) $(PS_ITS_TRIMMED) $@

asv : $(METADATA_16S) $(METADATA_ITS)\
$(METAB) $(TREE_AGE) $(TREE_AGE_SITE)\
$(PS_16S_UNTRIMMED) $(PS_16S_TRIMMED) $(PS_ITS_UNTRIMMED) $(PS_ITS_TRIMMED)\
$(FINAL_16S_ASV) $(FINAL_ITS_ASV) $(FINAL_16S_META) $(FINAL_ITS_META)\
$(FINAL_16S_REPSEQS) $(FINAL_ITS_REPSEQS) $(FINAL_16S_TAX) $(FINAL_ITS_TAX)\
$(FINAL_16S_SUM) $(FINAL_ITS_SUM)

#### Split ASV tables by habitat ####

# 16S ASV tables
ASV_HAB_16S=data/processed/16S/asv_processed/BS_asv.txt data/processed/16S/asv_processed/RE_asv.txt data/processed/16S/asv_processed/RH_asv.txt

$(ASV_HAB_16S) : code/split_asv.R\
		$$(FINAL_16S_META)\
		$$(FINAL_16S_ASV)
	code/split_asv.R $(FINAL_16S_META) $(FINAL_16S_ASV) $@

# ITS ASV tables
ASV_HAB_ITS=data/processed/ITS/asv_processed/BS_asv.txt data/processed/ITS/asv_processed/RE_asv.txt data/processed/ITS/asv_processed/RH_asv.txt

$(ASV_HAB_ITS) : code/split_asv.R\
		$$(FINAL_ITS_META)\
		$$(FINAL_ITS_ASV)
	code/split_asv.R $(FINAL_ITS_META) $(FINAL_ITS_ASV) $@

#### Split metadata tables by habitat ####

# 16S metadata
MET_HAB_16S=$(subst _asv.txt,_metadata.txt,$(ASV_HAB_16S))

$(MET_HAB_16S) : code/split_metadata.R\
		$$(FINAL_16S_META)\
		$$(subst _metadata.txt,_asv.txt,$$@)
	code/split_metadata.R $(FINAL_16S_META) $(subst _metadata.txt,_asv.txt,$@) $@

# ITS metadata
MET_HAB_ITS=$(subst _asv.txt,_metadata.txt,$(ASV_HAB_ITS))

$(MET_HAB_ITS) : code/split_metadata.R\
		$$(FINAL_ITS_META)\
		$$(subst _metadata.txt,_asv.txt,$$@)
	code/split_metadata.R $(FINAL_ITS_META) $(subst _metadata.txt,_asv.txt,$@) $@

#### Split representative sequences fasta by habitat ####

# 16S representative sequences
REPSEQ_HAB_16S=$(subst _asv.txt,_representative_sequences.fasta,$(ASV_HAB_16S))

$(REPSEQ_HAB_16S) : code/split_repseqs.R\
		$$(FINAL_16S_REPSEQS)\
		$$(subst _representative_sequences.fasta,_asv.txt,$$@)
	code/split_repseqs.R $(FINAL_16S_REPSEQS) $(subst _representative_sequences.fasta,_asv.txt,$@) $@

# ITS representative sequences
REPSEQ_HAB_ITS=$(subst _asv.txt,_representative_sequences.fasta,$(ASV_HAB_ITS))

$(REPSEQ_HAB_ITS) : code/split_repseqs.R\
		$$(FINAL_ITS_REPSEQS)\
		$$(subst _representative_sequences.fasta,_asv.txt,$$@)
	code/split_repseqs.R $(FINAL_ITS_REPSEQS) $(subst _representative_sequences.fasta,_asv.txt,$@) $@

#### Split taxonomy tables by habitat ####

# 16S taxonomy
TAX_HAB_16S=$(subst _asv.txt,_taxonomy_table.txt,$(ASV_HAB_16S))

$(TAX_HAB_16S) : code/split_taxonomy.R\
		$$(FINAL_16S_TAX)\
		$$(subst _taxonomy_table.txt,_asv.txt,$$@)
	code/split_taxonomy.R $(FINAL_16S_TAX) $(subst _taxonomy_table.txt,_asv.txt,$@) $@

# ITS taxonomy
TAX_HAB_ITS=$(subst _asv.txt,_taxonomy_table.txt,$(ASV_HAB_ITS))

$(TAX_HAB_ITS) : code/split_taxonomy.R\
		$$(FINAL_ITS_TAX)\
		$$(subst _taxonomy_table.txt,_asv.txt,$$@)
	code/split_taxonomy.R $(FINAL_ITS_TAX) $(subst _taxonomy_table.txt,_asv.txt,$@) $@

#### Rarefaction curves ####

# Generate 16S rarefaction curves
RARECURVE_16S=$(subst _asv.txt,_rarefaction_curves.txt,$(ASV_HAB_16S))

$(RARECURVE_16S) : code/get_rarefaction_curves.R\
		$$(subst _rarefaction_curves.txt,_asv.txt,$$@)
	code/get_rarefaction_curves.R $(subst _rarefaction_curves.txt,_asv.txt,$@) $@

# Generate ITS rarefaction curves
RARECURVE_ITS=$(subst _asv.txt,_rarefaction_curves.txt,$(ASV_HAB_ITS))

$(RARECURVE_ITS) : code/get_rarefaction_curves.R\
		$$(subst _rarefaction_curves.txt,_asv.txt,$$@)
	code/get_rarefaction_curves.R $(subst _rarefaction_curves.txt,_asv.txt,$@) $@

# Make rarefaction curve figures
RARECURVE_FIG=results/rarefaction_curves_fig.rds

$(RARECURVE_FIG) : code/make_rarefaction_curve_plots.R\
		$$(MET_HAB_16S)\
		$$(MET_HAB_ITS)\
		$$(RARECURVE_16S)\
		$$(RARECURVE_ITS)
	code/make_rarefaction_curve_plots.R $(MET_HAB_16S) $(MET_HAB_ITS) $(RARECURVE_16S) $(RARECURVE_ITS) $@

# Save pdf of rarefaction curve figures
results/rarefaction_curves_fig.pdf : code/save_figure.R\
		$$(subst .pdf,.rds,$$@)
	code/save_figure.R $(subst .pdf,.rds,$@) "pdf" "NULL" "6.5" "8" "in" $@

#### Total sequence counts by sample ####

# Get sequence totals
SAMPLE_SEQ_TOTAL=$(subst _asv.txt,_sample_total.txt,$(ASV_HAB_16S))\
$(subst _asv.txt,_sample_total.txt,$(ASV_HAB_ITS))

$(SAMPLE_SEQ_TOTAL) : code/get_sample_sequence_totals.R\
		$$(subst _sample_total.txt,_asv.txt,$$@)
	code/get_sample_sequence_totals.R $(subst _sample_total.txt,_asv.txt,$@) $@

# Make sequence total figures
SAMPLE_SEQ_TOTAL_FIG=results/sample_sequence_totals_fig.rds

$(SAMPLE_SEQ_TOTAL_FIG) : code/make_sample_sequence_total_plots.R\
		$$(MET_HAB_16S)\
		$$(MET_HAB_ITS)\
		$$(SAMPLE_SEQ_TOTAL)
	code/make_sample_sequence_total_plots.R $(MET_HAB_16S) $(MET_HAB_ITS) $(SAMPLE_SEQ_TOTAL) $@

# Save pdf of sequence total figures
results/sample_sequence_totals_fig.pdf : code/save_figure.R\
		$$(subst .pdf,.rds,$$@)
	code/save_figure.R $(subst .pdf,.rds,$@) "pdf" "NULL" "6.5" "8" "in" $@

#### Subsample tables ####

# Subsample with ranked scaling (SRS)
ASV_SUB=$(subst _asv.txt,_sub_asv.txt,$(ASV_HAB_16S))\
$(subst _asv.txt,_sub_asv.txt,$(ASV_HAB_ITS))

$(ASV_SUB) : code/get_sub_asv.R\
		$$(subst _sub_asv.txt,_asv.txt,$$@)
	code/get_sub_asv.R $(subst _sub_asv.txt,_asv.txt,$@) $@

# Metadata
METADATA_SUB=$(subst _sub_asv.txt,_sub_metadata.txt,$(ASV_SUB))

$(METADATA_SUB) : code/get_sub_metadata.R\
		$$(subst _sub_metadata.txt,_sub_asv.txt,$$@)\
		$$(subst _sub_metadata.txt,_metadata.txt,$$@)
	code/get_sub_metadata.R $(subst _sub_metadata.txt,_sub_asv.txt,$@) $(subst _sub_metadata.txt,_metadata.txt,$@) $@

# Representative sequences
REPSEQ_SUB=$(subst _sub_asv.txt,_sub_representative_sequences.fasta,$(ASV_SUB))

$(REPSEQ_SUB) : code/get_sub_repseqs.R\
		$$(subst _sub_representative_sequences.fasta,_sub_asv.txt,$$@)\
		$$(subst _sub_representative_sequences.fasta,_representative_sequences.fasta,$$@)
	code/get_sub_repseqs.R $(subst _sub_representative_sequences.fasta,_sub_asv.txt,$@) $(subst _sub_representative_sequences.fasta,_representative_sequences.fasta,$@) $@

# Metadata
TAX_SUB=$(subst _sub_asv.txt,_sub_taxonomy_table.txt,$(ASV_SUB))

$(TAX_SUB) : code/get_sub_taxonomy.R\
		$$(subst _sub_taxonomy_table.txt,_sub_asv.txt,$$@)\
		$$(subst _sub_taxonomy_table.txt,_taxonomy_table.txt,$$@)
	code/get_sub_taxonomy.R $(subst _sub_taxonomy_table.txt,_sub_asv.txt,$@) $(subst _sub_taxonomy_table.txt,_taxonomy_table.txt,$@) $@

subsample : $(ASV_HAB_16S) $(ASV_HAB_ITS)\
$(MET_HAB_16S) $(MET_HAB_ITS) $(REPSEQ_HAB_16S) $(REPSEQ_HAB_ITS)\
$(TAX_HAB_16S) $(TAX_HAB_ITS) $(RARECURVE_16S) $(RARECURVE_ITS)\
$(RARECURVE_FIG) results/rarefaction_curves_fig.pdf\
$(SAMPLE_SEQ_TOTAL) $(SAMPLE_SEQ_TOTAL_FIG) results/sample_sequence_totals_fig.pdf\
$(ASV_SUB) $(METADATA_SUB) $(REPSEQ_SUB) $(TAX_SUB)

#### Alpha diversity ####


#### 16S and ITS dbRDA ####

# Run dbRDA
DBRDA=$(subst _sub_asv.txt,_dbrda.rds,$(subst /asv_processed/,/dbrda/,$(ASV_SUB)))

$(DBRDA) : code/run_dbrda.R\
		$$(subst _dbrda.rds,_sub_asv.txt,$$(subst /dbrda/,/asv_processed/,$$@))\
		$$(subst _dbrda.rds,_sub_metadata.txt,$$(subst /dbrda/,/asv_processed/,$$@))\
		$$(TREE_AGE_SITE)
	code/run_dbrda.R $(subst _dbrda.rds,_sub_asv.txt,$(subst /dbrda/,/asv_processed/,$@)) $(subst _dbrda.rds,_sub_metadata.txt,$(subst /dbrda/,/asv_processed/,$@)) $(TREE_AGE_SITE) $@

# Run dbRDA ANOVA
DBRDA_ANOVA=$(subst _dbrda.rds,_dbrda_anova.txt,$(DBRDA))

$(DBRDA_ANOVA) : code/run_dbrda_anova.R\
		$$(subst _dbrda_anova.txt,_dbrda.rds,$$@)
	code/run_dbrda_anova.R $(subst _dbrda_anova.txt,_dbrda.rds,$@) $@

#### Metabolites dbRDA ####

# Run metabolite dbRDA
data/processed/dbrda/metabolite_dbrda.rds : code/run_dbrda_metabolites.R\
		$$(METAB)\
		$$(METADATA_SUB)\
		$$(TREE_AGE_SITE)
	code/run_dbrda_metabolites.R $(METAB) $(METADATA_SUB) $(TREE_AGE_SITE) $@

# Run dbRDA ANOVA
results/metabolite_dbrda_anova.txt : code/run_dbrda_anova.R\
		data/processed/dbrda/metabolite_dbrda.rds
	code/run_dbrda_anova.R data/processed/dbrda/metabolite_dbrda.rds $@

dbrda : $(DBRDA) $(DBRDA_ANOVA) data/processed/dbrda/metabolite_dbrda.rds\
results/metabolite_dbrda_anova.txt

#### 16S and ITS TITAN2 ####

# Prepare 16S and ITS TITAN2 input data
TITAN_IN=$(subst _sub_asv.txt,_titan_input.rds,$(subst /asv_processed/,/titan/,$(ASV_SUB)))

$(TITAN_IN) : code/get_titan_input.R\
		$$(subst _titan_input.rds,_sub_asv.txt,$$(subst /titan/,/asv_processed/,$$@))\
		$$(subst _titan_input.rds,_sub_metadata.txt,$$(subst /titan/,/asv_processed/,$$@))\
		$$(TREE_AGE_SITE)
	code/get_titan_input.R $(subst _titan_input.rds,_sub_asv.txt,$(subst /titan/,/asv_processed/,$@)) $(subst _titan_input.rds,_sub_metadata.txt,$(subst /titan/,/asv_processed/,$@)) $(TREE_AGE_SITE) $@

# Run 16S and ITS TITAN2
TITAN_OUT=$(subst _titan_input.rds,_titan_output.rds,$(TITAN_IN))

$(TITAN_OUT) : code/run_titan.R\
		$$(subst _titan_output.rds,_titan_input.rds,$$@)
	code/run_titan.R $(subst _titan_output.rds,_titan_input.rds,$@) $@

# 16S and ITS TITAN2 fzumz
data/processed/titan/titan_fsumz.txt : code/get_titan_fsumz.R\
		$$(TITAN_OUT)
	code/get_titan_fsumz.R $(TITAN_OUT) $@

# 16S and ITS TITAN2 OTUs
data/processed/titan/titan_asv.txt : code/get_titan_asv.R\
		$$(TITAN_OUT)\
		$$(TAX_SUB)
	code/get_titan_asv.R $(TITAN_OUT) $(TAX_SUB) $@

# TITAN2 Bartlett test
results/titan_bartlett.txt : code/run_titan_bartlett.R\
		data/processed/titan/titan_fsumz.txt
	code/run_titan_bartlett.R data/processed/titan/titan_fsumz.txt $@

# TITAN2 paired t-test
results/titan_paired_ttest.txt : code/run_titan_paired_ttest.R\
		data/processed/titan/titan_fsumz.txt
	code/run_titan_paired_ttest.R data/processed/titan/titan_fsumz.txt $@

# Make fsumz figure
results/titan_fsumz_fig.rds : code/make_titan_fsumz_fig.R\
		data/processed/titan/titan_fsumz.txt\
		results/titan_paired_ttest.txt
	code/make_titan_fsumz_fig.R data/processed/titan/titan_fsumz.txt results/titan_paired_ttest.txt $@

# Save fsumz figure as a pdf
results/titan_fsumz_fig.pdf : code/save_figure.R\
		results/titan_fsumz_fig.rds
	code/save_figure.R results/titan_fsumz_fig.rds "pdf" "NULL" "6.5" "5" "in" $@

#### Metabolite TITAN2 ####

# Metabolite TITAN input data
data/processed/titan/metabolite_titan_input.rds : code/get_metabolite_titan_input.R\
		$$(METAB)\
		$$(FINAL_16S_META)\
		$$(FINAL_ITS_META)\
		$$(TREE_AGE_SITE)
	code/get_metabolite_titan_input.R $(METAB) $(FINAL_16S_META) $(FINAL_ITS_META) $(TREE_AGE_SITE) $@

# Metabolite TITAN
data/processed/titan/metabolite_titan_output.rds : code/run_titan_metabolites.R\
		data/processed/titan/metabolite_titan_input.rds
	code/run_titan_metabolites.R data/processed/titan/metabolite_titan_input.rds $@

# titan2 : $(TITAN_IN) $(TITAN_OUT) data/processed/titan/titan_fsumz.txt\
# data/processed/titan/titan_asv.txt results/titan_bartlett.txt\
# results/titan_paired_ttest.txt results/titan_fsumz_fig.rds results/titan_fsumz_fig.pdf\
# data/processed/titan/metabolite_titan_input.rds data/processed/titan/metabolite_titan_output.rds

titan2 : data/processed/titan/metabolite_titan_input.rds data/processed/titan/metabolite_titan_output.rds