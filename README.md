This is a pipeline for calling *de novo* mutations in parent-offspring trios.

Suggested usage:
1. Install dependencies from github (this pipeline, vr-runner, samtools, bcftools)
   ```
   wget -qO- \
     https://raw.githubusercontent.com/HurlesGroupSanger/trio-dnm-calling/refs/heads/main/install.sh |
     bash -s install_dir

   # set the paths: either add to your profile or execute before running the pipelines below
   . install_dir/setenv.sh
   ```
2. Call candidate DNM sites
   ```
   # create and edit a config file
   cp install_dir/trio-dnm-calling/template.candidate-calls.conf candidates.conf

   # run locally or run on a farm
   run-commands +config candidate-calls.conf -o out.candidates -i /path/to/input/vcfs +local
   run-commands +config candidate-calls.conf -o out.candidates -i /path/to/input/vcfs +loop 300
   ```
3. Run bcftools/trio-dnm and vrfs
   ```
   # create and edit a config file
   cp install_dir/trio-dnm-calling/template.trio-dnm.conf trio-dnm.conf

   # run the pipeline, locally or on a farm
   run-trio-dnm +config trio-dnm.conf -o outdir -s out.candidates/sites.txt.gz +local
   run-trio-dnm +config trio-dnm.conf -o outdir -s out.candidates/sites.txt.gz +loop 300
   ```
