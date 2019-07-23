#public class ESPPredictor
#{
#  public static void main(String[] paramArrayOfString) {
#    List list = CmdSplitter.split(paramArrayOfString, "zzz");
#    if (list.size() != 2) {
#      System.err.println("Command args error");
#      System.err.println(Arrays.toString((Object[])list.get(0)));
#      System.exit(1);
#    } 
#    try {
#      Matlab.main((String[])list.get(0));
#      RInterpreter.main((String[])list.get(1));
#    } catch (Exception exception) {
#      exception.printStackTrace();
#    } 
#  }
#}

# rename the input file to get around the compiled matlab not being happy with spaces in filenames
cp "$1" input.txt
/ESPPredictor/run_matlab.sh input.txt

# presumably the R looks for a known local file
Rscript /ESPPredictor/ESP_Predictor.R Predict ./PeptideFeatureSet.csv /ESPPredictor/ESP_Predictor_Model_020708.RData /ESPPredictor

rm input.txt

