import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'predict_viewmodel.dart';

class PredictView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PredictViewModel>.reactive(
      viewModelBuilder: () => PredictViewModel(),
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: Colors.black12,
          appBar: AppBar(
            backgroundColor: Colors.yellow,
            title: const Text("Prediction"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Month Field
                TextFormField(
                  validator: (value){
                    if(value!.isEmpty){
                      return "Select an month";
                    }
                  },
                  controller: model.monthController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Select Month",labelStyle: TextStyle(color: Colors.blueAccent),
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      model.setMonth(selectedDate);
                    }
                  },
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                // Year Field
                TextFormField(
                  validator: (value){
                    if(value!.isEmpty){
                      return "Select an Year";
                    }
                  },
                  controller: model.yearController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Select Year",
                    labelStyle: TextStyle(color: Colors.blueAccent),
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      model.setYear(selectedDate);
                    }
                  },
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                // Kids Field
                TextFormField(
                  validator: (value){
                    if (value!.isEmpty){
                      return ("Enter the number");
                    }
                  },
                  controller: model.kidsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Number of Kids",
                    labelStyle: TextStyle(color: Colors.blueAccent),
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                // Adults Field
                TextFormField(
                  validator: (value){
                    if(value!.isEmpty){
                      return "Enter a number";
                    }
                  },
                  controller: model.adultsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Number of Adults",
                    labelStyle: TextStyle(color: Colors.blueAccent),
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                // Predict Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black12,
                    side: BorderSide(color: Colors.white38)
                  ),
                  onPressed: () => model.savePrediction(),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Predict",),
                      SizedBox(width: 2,),
                      Icon(Icons.multitrack_audio_outlined),
                    ],
                  ),

                ),
                const SizedBox(height: 32),
                // Loading Indicator or Prediction Value
                if (model.isLoading)
                  const CircularProgressIndicator()
                else if (model.prediction != null)
                  Text(
                    "Prediction Value: ${model.prediction}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.blueAccent),
                  )
                else
                  const Text("No prediction yet",style: TextStyle(color: Colors.blueAccent),),
              ],
            ),
          ),
        );
      },
    );
  }
}
