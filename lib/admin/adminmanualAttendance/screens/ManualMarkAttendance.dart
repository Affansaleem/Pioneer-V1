import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:project/constants/AppBar_constant.dart';
import 'package:project/constants/AppColor_constants.dart';
import 'package:project/introduction/bloc/bloc_internet/internet_bloc.dart';
import 'package:project/introduction/bloc/bloc_internet/internet_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../No_internet/no_internet.dart';
import '../../adminReportsFiles/bloc/getActiveEmployeeApiFiles/get_active_employee_bloc.dart';
import '../../adminReportsFiles/bloc/getActiveEmployeeApiFiles/get_active_employee_event.dart';
import '../../adminReportsFiles/bloc/getActiveEmployeeApiFiles/get_active_employee_state.dart';
import '../../adminReportsFiles/models/branchRepository.dart';
import '../../adminReportsFiles/models/companyRepository.dart';
import '../../adminReportsFiles/models/departmentModel.dart';
import '../../adminReportsFiles/models/departmentRepository.dart';
import '../../adminReportsFiles/models/getActiveEmployeesModel.dart';
import 'SubmitAttendance.dart';

class ManualMarkAttendance extends StatefulWidget {
  @override
  _ManualMarkAttendanceState createState() => _ManualMarkAttendanceState();
}

class _ManualMarkAttendanceState extends State<ManualMarkAttendance> {
  String corporateId = '';
  List<GetActiveEmpModel> employees = [];
  List<GetActiveEmpModel> selectedEmployees = [];
  bool selectAll = false;
  final TextEditingController _remarksController = TextEditingController();
  String filterOption = 'Default'; // Initialize with Default
  String filterId = '';
  List<String> departmentNames = [];
  String? departmentDropdownValue;
  String searchQuery = '';
  Department? selectedDepartment;
  String? branchDropdownValue;
  List<String> branchNames = [];
  String? companyDropdownValue;
  List<String> companyNames = [];

  @override
  void initState() {
    super.initState();
    _fetchCorporateIdFromPrefs();
    _fetchDepartmentNames();
    _fetchBranchNames(); // Fetch department names when the widget initializes
    _fetchCompanyNames(); // Fetch company names when the widget initializes
    companyDropdownValue = null;
  }

  Future<void> _fetchDepartmentNames() async {
    try {
      final departments =
          await DepartmentRepository().getAllActiveDepartments(corporateId);

      // Extract department names from the departments list and filter out null values
      final departmentNames = departments
          .map((department) => department.deptName)
          .where((name) => name != null) // Filter out null values
          .map((name) => name!) // Convert non-nullable String? to String
          .toList();

      setState(() {
        this.departmentNames = departmentNames;
      });
    } catch (e) {
      print('Error fetching department names: $e');
    }
  }

  Future<void> _fetchCorporateIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final storedCorporateId = prefs.getString('corporate_id');
    print("Stored corporate id: $storedCorporateId");
    setState(() {
      corporateId = storedCorporateId ?? '';
    });

    context.read<GetEmployeeBloc>().add(FetchEmployees(corporateId));
  }

  void _navigateToNextScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            SubmitAttendance(selectedEmployees: selectedEmployees),
      ),
    );
  }

  Future<void> _fetchBranchNames() async {
    try {
      final branches =
          await BranchRepository().getAllActiveBranches(corporateId);

      // Extract branch names from the branches list and filter out null values
      final branchNames = branches
          .map((branch) => branch.branchName)
          .where((name) => name != null) // Filter out null values
          .map((name) => name) // Convert non-nullable String? to String
          .toList();

      setState(() {
        this.branchNames = branchNames;
      });
    } catch (e) {
      print('Error fetching branch names: $e');
    }
  }

  Future<void> _fetchCompanyNames() async {
    try {
      // Replace with the actual method to fetch company names
      final companies =
          await CompanyRepository().getAllActiveCompanies(corporateId);

      // Extract company names from the companies list and filter out null values
      final companyNames = companies
          .map((company) => company.companyName)
          .where((name) => name != null) // Filter out null values
          .map((name) => name!) // Convert non-nullable String? to String
          .toList();

      setState(() {
        this.companyNames = companyNames;
      });
    } catch (e) {
      print('Error fetching company names: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.watch<GetEmployeeBloc>().state;

    if (state is GetEmployeeLoaded) {
      final employees = state.employees;
      setState(() {
        this.employees = employees;
      });
      _updateSelectAll(); // Call this method to update the select all checkbox
    }
  }

  void _toggleEmployeeSelection(GetActiveEmpModel employee) {
    setState(() {
      employee.isSelected = !employee.isSelected;
      if (employee.isSelected) {
        selectedEmployees.add(employee);
      } else {
        selectedEmployees.remove(employee);
      }
      print('Employee ${employee.empName} isSelected: ${employee.isSelected}');
      print('Selected Employees: $selectedEmployees');
    });
  }

  void _updateSelectAll() {
    bool allSelected = employees.every((employee) => employee.isSelected);
    setState(() {
      selectAll = allSelected;
    });
  }

  void _toggleSelectAll() {
    setState(() {
      selectAll = !selectAll;
      print('Select All: $selectAll');

      for (var employee in employees) {
        employee.isSelected = selectAll;
      }

      // Update the selectedEmployees list to match the selected state
      if (selectAll) {
        selectedEmployees = List.from(employees);
      } else {
        selectedEmployees.clear();
      }
      print('Selected Employees: $selectedEmployees');
    });
  }

  void _showRemarksDialog(GetActiveEmpModel employee) {
    _remarksController.text = employee.remarks;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Remarks'),
          content: TextField(
            controller: _remarksController,
            decoration: const InputDecoration(
              hintText: 'Enter remarks...',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Update the remarks when OK is pressed
                employee.remarks = _remarksController.text;
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  bool _employeeMatchesFilter(GetActiveEmpModel employee) {
    bool departmentMatch = true;
    bool branchMatch = true;
    bool companyMatch = true;

    // Check if a department is selected and match it with the employee's department
    if (departmentDropdownValue != null &&
        departmentDropdownValue!.isNotEmpty) {
      departmentMatch = employee.deptNames == departmentDropdownValue;
    }

    // Check if a branch is selected and match it with the employee's branch
    if (branchDropdownValue != null && branchDropdownValue!.isNotEmpty) {
      branchMatch = employee.branchNames == branchDropdownValue;
    }

    // Check if a company is selected and match it with the employee's company
    if (companyDropdownValue != null && companyDropdownValue!.isNotEmpty) {
      companyMatch = employee.companyNames == companyDropdownValue;
    }

    // Check if the search query matches employee's name or code
    bool searchMatch = searchQuery.isEmpty ||
        (employee.empName?.toLowerCase().contains(searchQuery.toLowerCase()) ??
            false) ||
        (employee.empCode?.toLowerCase().contains(searchQuery.toLowerCase()) ??
            false);

    // Return true if all conditions are met, otherwise, return false
    return departmentMatch && branchMatch && companyMatch && searchMatch;
  }

  List<GetActiveEmpModel> filterEmployees(
      List<GetActiveEmpModel> employees, String query) {
    return employees.where((employee) {
      bool matchesFilter = true;

      // Check if a department is selected and match it with the employee's department
      if (departmentDropdownValue != null &&
          departmentDropdownValue!.isNotEmpty) {
        matchesFilter =
            matchesFilter && employee.deptNames == departmentDropdownValue;
      }

      // Check if a branch is selected and match it with the employee's branch
      if (branchDropdownValue != null && branchDropdownValue!.isNotEmpty) {
        matchesFilter =
            matchesFilter && employee.branchNames == branchDropdownValue;
      }

      // Check if a company is selected and match it with the employee's company
      if (companyDropdownValue != null && companyDropdownValue!.isNotEmpty) {
        matchesFilter =
            matchesFilter && employee.companyNames == companyDropdownValue;
      }

      // Check if the search query matches employee's name, code, or EmpId
      bool searchMatch = query.isEmpty ||
          (employee.empName?.toLowerCase().contains(query.toLowerCase()) ??
              false) ||
          (employee.empCode?.toLowerCase().contains(query.toLowerCase()) ??
              false) ||
          (employee.empId.toString().contains(query)); // Check for EmpId match

      // Return true if all conditions are met (selected department, branch, company, and search query), otherwise, return false
      return matchesFilter && searchMatch;
    }).toList();
  }

  bool isInternetLost = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InternetBloc, InternetStates>(
      listener: (context, state) {
        // TODO: implement listener
        if (state is InternetLostState) {
          // Set the flag to true when internet is lost
          isInternetLost = true;
          Future.delayed(Duration(seconds: 2), () {
            Navigator.push(
              context,
              PageTransition(
                child: NoInternet(),
                type: PageTransitionType.rightToLeft,
              ),
            );
          });
        } else if (state is InternetGainedState) {
          // Check if internet was previously lost
          if (isInternetLost) {
            // Navigate back to the original page when internet is regained
            Navigator.pop(context);
          }
          isInternetLost = false; // Reset the flag
        }
      },
      builder: (context, state) {
        if (state is InternetGainedState)
          {
            return Scaffold(
              appBar: AppBar(
                iconTheme: IconThemeData(color: AppBarStyles.appBarIconColor),
                backgroundColor: AppBarStyles.appBarBackgroundColor,
                title: const Text(
                  'Manual Mark',
                  style:
                  AppBarStyles.appBarTextStyle
                ),
                actions: <Widget>[
                  // Add a Save button to the app bar
                  TextButton(
                    onPressed: () {
                      _navigateToNextScreen();
                    },
                    child:  const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400
                      ),
                    ),
                  ),
                ],
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        color: AppColors.secondaryColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(
                                "FILTERS",
                                style: GoogleFonts.openSans(
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 10),
                              // Department Dropdown
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Department:',
                                    style: GoogleFonts.openSans(
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: departmentDropdownValue,
                                      onChanged: (newValue) {
                                        setState(() {
                                          departmentDropdownValue = newValue!;
                                        });
                                      },
                                      items: [
                                        DropdownMenuItem<String>(
                                          value: '',
                                          child: Text(
                                            'All',
                                            style: GoogleFonts.openSans(
                                              textStyle: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        ...departmentNames.map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: GoogleFonts.openSans(
                                                textStyle: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              // Branch Dropdown
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Branch:',
                                    style: GoogleFonts.openSans(
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: branchDropdownValue,
                                      onChanged: (newValue) {
                                        setState(() {
                                          branchDropdownValue = newValue!;
                                        });
                                      },
                                      items: [
                                        DropdownMenuItem<String>(
                                          value: '',
                                          child: Text(
                                            'All',
                                            style: GoogleFonts.openSans(
                                              textStyle: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        ...branchNames.map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: GoogleFonts.openSans(
                                                textStyle: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              // Company Dropdown
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Company:',
                                    style: GoogleFonts.openSans(
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: companyDropdownValue,
                                      onChanged: (newValue) {
                                        setState(() {
                                          companyDropdownValue = newValue!;
                                        });
                                      },
                                      items: [
                                        DropdownMenuItem<String>(
                                          value: '',
                                          child: Text(
                                            'All',
                                            style: GoogleFonts.openSans(
                                              textStyle: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        ...companyNames.map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: GoogleFonts.openSans(
                                                textStyle: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              // Search Bar
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Search:',
                                    style: GoogleFonts.openSans(
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors
                                          .white, // Change background color to white
                                      border: Border.all(
                                        color: Colors.white,
                                      ),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          searchQuery = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Search by name or code...',
                                        icon: Icon(Icons.search,
                                            color: Colors
                                                .black), // Change icon color to black
                                        hintStyle: GoogleFonts.openSans(
                                          textStyle: const TextStyle(
                                            fontSize: 14,
                                            color: Colors
                                                .black, // Change hint text color to black
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal:
                                            12.0), // Adjust padding as needed
                                        border: InputBorder
                                            .none, // Remove the default border
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // "Select All" Button
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                          MaterialStatePropertyAll(AppColors.lightBlue)),
                      onPressed: _toggleSelectAll,
                      child: Text(
                        selectAll ? 'Deselect All' : 'Select All',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // Employee List in DataTable form
                    SingleChildScrollView(
                      scrollDirection:
                      Axis.horizontal, // Enable horizontal scrolling
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border:
                          Border.all(color: Colors.black), // Add border styling
                        ),
                        child: DataTable(
                          headingRowColor: MaterialStatePropertyAll(
                            AppColors.primaryColor,
                          ),
                          columnSpacing: 20.0,
                          columns: const [
                            DataColumn(
                                label: Text(
                                  'ID',
                                  style: TextStyle(fontSize: 12, color: Colors.white),
                                )),
                            DataColumn(
                                label: Text(
                                  'Name',
                                  style: TextStyle(fontSize: 12, color: Colors.white),
                                )),
                            DataColumn(
                              label: Text(
                                'Department',
                                style: TextStyle(fontSize: 12, color: Colors.white),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Branch',
                                style: TextStyle(fontSize: 12, color: Colors.white),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                '',
                                style: TextStyle(fontSize: 12, color: Colors.white),
                              ),
                            ), // Add Remarks column
                            DataColumn(
                              label: Text(
                                '',
                                style: TextStyle(fontSize: 12, color: Colors.white),
                              ),
                            ),
                          ],
                          rows: filterEmployees(employees, searchQuery)
                              .map((employee) {
                            return DataRow(
                              cells: [
                                DataCell(Text(
                                  employee.empCode.toString(),
                                  style: const TextStyle(fontSize: 12),
                                )),
                                DataCell(Text(
                                  employee.empName ?? '',
                                  style: const TextStyle(fontSize: 12),
                                )),
                                DataCell(Text(
                                  employee.deptNames ?? '',
                                  style: const TextStyle(fontSize: 12),
                                )),
                                DataCell(Text(
                                  employee.branchNames ?? '',
                                  style: const TextStyle(fontSize: 12),
                                )), // Ensure BranchName data is available
                                DataCell(
                                  SizedBox(
                                    width: 100, // Adjust the width as needed
                                    height: 30, // Adjust the height as needed
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _showRemarksDialog(employee);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets
                                            .zero, // Remove padding around the button text
                                      ),
                                      child: const Text(
                                        'Remarks',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ),

                                DataCell(
                                  Checkbox(
                                    value: employee.isSelected,
                                    onChanged: (_) {
                                      _toggleEmployeeSelection(employee);
                                    },
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        else
        {
          return Scaffold(
            body: Center(
                child: CircularProgressIndicator()),
          );
        }

      },
    );
  }
}
