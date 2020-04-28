# load Random Forest library                        

Predict = function (featureFile, modelName, libdir) {
	# test for existance of the feature file

  if (file.access("PeptideFeatureSet.csv", mode=0) == -1) 
    stop("The feature file was not generated - MATLAB error probably non-standard amino acid J,U,Z,B,O,X") 

	# source("/ESPPredictor/common.R")
    suppressMessages(library(randomForest))
  	
  	# set the model data
  	load(modelName)
  	
  	# name of output file
  	outputFile = 'Prediction.txt'
  	
  	# load data
  	predict.data <- read.table(featureFile, header=TRUE, sep=",")                                     
  	
  	# calculate predictions from model
  	peptide.pred <- predict(peptide.rf, predict.data[,-1], type="prob")
  	prediction = data.frame(Sequence = predict.data$sequence, ESP_Prediction = peptide.pred[,1])
  	
  	# write the results
  	write.table(prediction, file=outputFile, append=F, sep="\t", quote=F, row.names=F)
}
args <- commandArgs()
Predict(args[7], args[8])
