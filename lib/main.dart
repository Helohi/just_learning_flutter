import 'package:flutter/material.dart';
import 'package:path_provider_lesson/db/database.dart';
import 'package:path_provider_lesson/model/student.dart';

void main() => runApp(const MyMaterialApp());

class MyMaterialApp extends StatelessWidget {
  const MyMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();

  late final Future<List<Student>> _studentsList;
  String _studentName = '';
  bool isUpdate = false;
  int? studentIdForUpdate;

  @override
  void initState() {
    super.initState();
    updateStudentsList();
  }

  void updateStudentsList() {
    setState(() {
      _studentsList = DBProvider.db.getStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('SQLite CRUD Demo'),
      ),
      body: Column(
        children: [
          Form(
            key: _formStateKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Padding(
              padding: const EdgeInsets.only(right: 10, left: 10, bottom: 10),
              child: TextFormField(
                validator: (value) {
                  if (value == null) return 'Please Enter Student Name';
                  if (value.trim() == '') return 'Only Space is Not Valid';
                  return null;
                },
                onSaved: (newValue) {
                  _studentName = newValue ?? '';
                },
                controller: _studentNameController,
                decoration: const InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.greenAccent,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  labelText: 'Student Name',
                  icon: Icon(Icons.people),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  if (isUpdate) {
                    if (_formStateKey.currentState!.validate()) {
                      _formStateKey.currentState!.save();
                      DBProvider.db
                          .updateStudent(
                        Student(
                          id: studentIdForUpdate,
                          name: _studentName,
                        ),
                      )
                          .then(
                        (value) {
                          setState(() {
                            isUpdate = false;
                          });
                        },
                      );
                    }
                  } else {
                    if (_formStateKey.currentState!.validate()) {
                      _formStateKey.currentState!.save();
                      DBProvider.db.insertStudent(Student(name: _studentName));
                    }
                  }
                  _studentNameController.text = '';
                  updateStudentsList();
                },
                child: Text(isUpdate ? 'UPDATE' : 'ADD'),
              ),
              const SizedBox(width: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  _studentNameController.text = '';
                  setState(() {
                    isUpdate = false;
                    studentIdForUpdate = null;
                  });
                },
                child: Text(isUpdate ? 'CANCEL UPDATE' : 'CLEAR'),
              ),
            ],
          ),
          const Divider(height: 5.0),
          Expanded(
              child: FutureBuilder(
            future: _studentsList,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return generateList(context, snapshot.data!);
              }
              if (snapshot.data == null || snapshot.data!.isEmpty) {
                return const Text('No Data Found');
              }
              return const CircularProgressIndicator();
            },
          )),
        ],
      ),
    );
  }

  SingleChildScrollView generateList(
      BuildContext context, List<Student> students) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('NAME')),
            DataColumn(label: Text('DELETE'))
          ],
          rows: students
              .map(
                (student) => DataRow(
                  cells: [
                    DataCell(
                      Text(student.name),
                      onTap: () {
                        setState(() {
                          isUpdate = true;
                          studentIdForUpdate = student.id;
                        });
                        _studentNameController.text = student.name;
                      },
                    ),
                    DataCell(
                      IconButton(
                        onPressed: () {
                          DBProvider.db.deleteStudent(student.id!);
                          updateStudentsList();
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
