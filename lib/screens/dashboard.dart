import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/components/my_drawer.dart';
import 'package:firebase_app/helpers/firebase_helper.dart';
import 'package:firebase_app/helpers/firestore_helper.dart';
import 'package:firebase_app/models/employee_model.dart';
import 'package:firebase_app/variables..dart';
import 'package:flutter/material.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final GlobalKey<FormState> insertFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> updateFormKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController roleController = TextEditingController();

  final TextEditingController nameUpdateController = TextEditingController();
  final TextEditingController ageUpdateController = TextEditingController();
  final TextEditingController roleUpdateController = TextEditingController();

  String? name;
  int? age;
  String? role;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new),
            onPressed: () async {
              await FirebaseHelper.firebaseHelper.logOut();

              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (routes) => false);
            },
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('employees').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

            int max = int.parse(docs[0].id);
            for (int i = 0; i < docs.length; i++) {
              if (max < int.parse(docs[i].id)) {
                max = int.parse(docs[i].id);
              }
            }

            Global.lastId = (docs.isNotEmpty) ? "$max" : "0";

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, i) {
                Map<String, dynamic> empData =
                    docs[i].data() as Map<String, dynamic>;

                // Global.lastId = docs[docs.length - 1].id;

                return Card(
                  elevation: 3,
                  child: ListTile(
                    isThreeLine: true,
                    leading: Text("${docs[i].id}"),
                    title: Text("${empData['name']}"),
                    subtitle: Text(
                        "Role: ${empData['role']}\nAge: ${empData['age']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                nameUpdateController.text = empData['name'];
                                ageUpdateController.text =
                                    empData['age'].toString();
                                roleUpdateController.text = empData['role'];

                                return AlertDialog(
                                  title: const Center(
                                      child: Text("Update Record")),
                                  content: Form(
                                    key: updateFormKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextFormField(
                                          controller: nameUpdateController,
                                          validator: (val) {
                                            if (val!.isEmpty) {
                                              return "Enter name first...";
                                            }
                                            return null;
                                          },
                                          onSaved: (val) {
                                            setState(() {
                                              name = val;
                                            });
                                          },
                                          decoration: const InputDecoration(
                                            label: Text("Name"),
                                            hintText: "Enter your name here...",
                                            border: const OutlineInputBorder(),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        TextFormField(
                                          controller: ageUpdateController,
                                          keyboardType: TextInputType.number,
                                          validator: (val) {
                                            if (val!.isEmpty) {
                                              return "Enter age first...";
                                            }
                                            return null;
                                          },
                                          onSaved: (val) {
                                            setState(() {
                                              age = int.parse(val!);
                                            });
                                          },
                                          decoration: const InputDecoration(
                                            label: Text("Age"),
                                            hintText: "Enter your age here...",
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        TextFormField(
                                          controller: roleUpdateController,
                                          validator: (val) {
                                            if (val!.isEmpty) {
                                              return "Enter role first...";
                                            }
                                            return null;
                                          },
                                          onSaved: (val) {
                                            setState(() {
                                              role = val;
                                            });
                                          },
                                          decoration: const InputDecoration(
                                            label: const Text("Role"),
                                            hintText: "Enter your role here...",
                                            border: const OutlineInputBorder(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      child: const Text("Update"),
                                      onPressed: () {
                                        if (updateFormKey.currentState!
                                            .validate()) {
                                          updateFormKey.currentState!.save();

                                          Map<String, dynamic> data = {
                                            'name': name,
                                            'age': age,
                                            'role': role,
                                          };

                                          Employee e = Employee.fromMap(data);

                                          FirestoreHelper.firestoreHelper
                                              .updateData(
                                                  data: e, id: docs[i].id);
                                        }

                                        nameUpdateController.clear();
                                        ageUpdateController.clear();
                                        roleUpdateController.clear();

                                        setState(() {
                                          name = "";
                                          age = 0;
                                          role = "";
                                        });

                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    OutlinedButton(
                                      child: const Text("Cancel"),
                                      onPressed: () {
                                        nameUpdateController.clear();
                                        ageUpdateController.clear();
                                        roleUpdateController.clear();

                                        setState(() {
                                          name = "";
                                          age = 0;
                                          role = "";
                                        });

                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Center(
                                  child: Text("Delete Record"),
                                ),
                                content: const Text(
                                    "Are you sure to delete this record?"),
                                actions: [
                                  ElevatedButton(
                                    child: const Text("Delete"),
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.redAccent,
                                      onPrimary: Colors.white,
                                    ),
                                    onPressed: () async {
                                      await FirestoreHelper.firestoreHelper
                                          .deleteData(id: docs[i].id);

                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  OutlinedButton(
                                    child: const Text("Cancel"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Center(child: Text("Insert Record")),
              content: Form(
                key: insertFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Enter name first...";
                        }
                        return null;
                      },
                      onSaved: (val) {
                        setState(() {
                          name = val;
                        });
                      },
                      decoration: const InputDecoration(
                        label: Text("Name"),
                        hintText: "Enter your name here...",
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Enter age first...";
                        }
                        return null;
                      },
                      onSaved: (val) {
                        setState(() {
                          age = int.parse(val!);
                        });
                      },
                      decoration: const InputDecoration(
                        label: Text("Age"),
                        hintText: "Enter your age here...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: roleController,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Enter role first...";
                        }
                        return null;
                      },
                      onSaved: (val) {
                        setState(() {
                          role = val;
                        });
                      },
                      decoration: const InputDecoration(
                        label: const Text("Role"),
                        hintText: "Enter your role here...",
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  child: const Text("Insert"),
                  onPressed: () {
                    if (insertFormKey.currentState!.validate()) {
                      insertFormKey.currentState!.save();

                      // Employee e = Employee(name: name, age: age, role: role);

                      Map<String, dynamic> data = {
                        'name': name,
                        'age': age,
                        'role': role,
                      };

                      Employee e = Employee.fromMap(data);

                      Global.lastId = "${int.parse(Global.lastId!) + 1}";

                      FirestoreHelper.firestoreHelper
                          .insertData(data: e, id: Global.lastId);
                    }

                    nameController.clear();
                    ageController.clear();
                    roleController.clear();

                    setState(() {
                      name = "";
                      age = 0;
                      role = "";
                    });

                    Navigator.of(context).pop();
                  },
                ),
                OutlinedButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    nameController.clear();
                    ageController.clear();
                    roleController.clear();

                    setState(() {
                      name = "";
                      age = 0;
                      role = "";
                    });

                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
