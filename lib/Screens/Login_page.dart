import 'package:examgo/Provider/auth_provider.dart';
import 'package:examgo/Screens/Signup_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String userType = "Teacher"; // Default selection
  bool isLoading = false;
  bool _obscureText = true;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
        child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25),
         height: MediaQuery.of(context).size.height - 50,
         width: double.infinity,
           child: Form(
           key: _formkey,
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             crossAxisAlignment: CrossAxisAlignment.stretch,
             children: <Widget>[
               const SizedBox(height: 50),
              Column(
                children: <Widget>[
                  const SizedBox(height: 30.0),
                  const Text(
                    "Exam Go",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Your Smart Exam Partner",
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  )
                ],
              ),
              const SizedBox(height:15),
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.lightBlueAccent.withValues(alpha: 0.1), // Light blue background
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.lightBlueAccent.withValues(alpha: 0.1),// Border color
                        width: 2, // Border width
                      ),
                    ),

                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: userType,
                        isExpanded: true,
                        dropdownColor: Colors.lightBlueAccent.withValues(alpha: 0.1), // Background color of dropdown
                        items: ["Teacher", "Student"].map((String role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(
                              role,
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            userType = newValue!;
                          });
                        },
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.lightBlueAccent.withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(15), // Rounded border for the dropdown list
                        menuMaxHeight: 200,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    textInputAction: TextInputAction.next,
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: "email",
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.lightBlueAccent.withValues(alpha: 0.1),
                      filled: true,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Password Input Field
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: "Password",
                      labelText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.lightBlueAccent.withValues(alpha: 0.1),
                      filled: true,
                      prefixIcon: const Icon(Icons.password_outlined),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                        child: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    obscureText: _obscureText,
                  ),

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.only(top: 3, left: 3),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 40),
                        backgroundColor: Colors.lightBlueAccent.withValues(alpha: 0.1), // Transparent Light Blue
                        foregroundColor: Colors.black, // Text color
                        shadowColor: Colors.transparent, // Removes shadow if needed
                      ),
                      onPressed: isLoading
                          ? null
                          : () async {
                        setState(() {
                          isLoading = true;
                        });

                         await Provider.of<AuthProvider>(context, listen: false)
                            .signInWithEmail(emailController.text, passwordController.text,userType,context);

                        setState(() {
                          isLoading = false;
                        });

                      },
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Sign In", style: TextStyle(fontSize: 20, color: Colors.black)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      "OR",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.5), // Black outline
                      borderRadius: BorderRadius.circular(25), // Rounded corners
                    ),
                  child: TextButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                      setState(() {
                        isLoading = true;
                      });

                       await Provider.of<AuthProvider>(context, listen: false).signInWithGoogle(userType, context);

                      setState(() {
                        isLoading = false;
                      });


                    },
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.blue)
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                       height: 30.0,
                       width: 30.0,
                      decoration: const BoxDecoration(
                       image: DecorationImage(
                         image: AssetImage('assets/images/google.jpg'),
                         fit: BoxFit.cover,
                       ),
                        shape: BoxShape.circle,
                      ),
                        ),
                        const SizedBox(width: 18),
                        const Text("Sign Up with Google",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black)),
                      ],
                    ),
                   ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPage()));
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(color: Colors.blue),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        )
    )
    )
    );
  }
}
