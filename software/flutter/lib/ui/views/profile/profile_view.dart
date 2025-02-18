import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'profile_viewmodel.dart';

class ProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfileViewModel>.reactive(
      viewModelBuilder: () => ProfileViewModel(),
      onViewModelReady: (model) => model.loadSavedData(),
      builder: (context, model, child) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // CircleAvatar to show the first letter of the name
                Row(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFFC8DBFF),
                      child: Text(
                        model.name.isNotEmpty ? model.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 10,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                       crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.name.isNotEmpty ? model.name : 'No Name',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          model.email.isNotEmpty ? model.email : 'No Email',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
                SizedBox(height: 40),
                _buildMenuItem(
                    onTap:(){
                      _showEditDialog(context, model);
                    } ,
                  title: 'Edit Personal Address'
                ),
            const SizedBox(height: 8),
            _buildMenuItem(
              title: 'Energy Usage History',
              onTap: () {
                // Handle navigation or action
              },
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              title: 'Help and Support',
              onTap: () {
                // Handle navigation or action
              },
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              title: 'Settings',
              onTap: () {
                // Handle navigation or action
              },
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              title: 'Logout',
              onTap: () {
                // Handle navigation or action
              },
              textColor: Colors.red,
            )
              ]
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFC8DBFF),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor ?? Colors.black87,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, ProfileViewModel model) {
    TextEditingController nameController =
        TextEditingController(text: model.name);
    TextEditingController emailController =
        TextEditingController(text: model.email);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Personal Address'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                model.saveData(nameController.text, emailController.text);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
