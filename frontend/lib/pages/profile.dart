import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/utils/jwt_helper.dart';
class ProfilePage extends StatelessWidget {
  final String username;
  const ProfilePage({super.key, required this.username});
  Future<bool?> showLogoutDialog(BuildContext context){
      return showDialog<bool>(context: context, builder: (BuildContext context){
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Padding(padding: EdgeInsets.all(20),child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Text(
                "Are you sure want to logout?",
                style: TextStyle(
                  fontFamily: "Manrope",
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "You will be logged out of the application",
                style: TextStyle(
                  fontFamily: "Manrope",
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: Color(0xFF55555A),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                      onPressed: (){
                        Navigator.pop(context,true);
                      },
                      style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Color(0xFF0461E5),
                            width: 1,

                          ),
                          minimumSize: Size(130, 40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                          )

                      ),
                      child:
                      Text("logout",style: TextStyle(color: Color(0xFF0461E5),),)
                  ),
                  ElevatedButton(onPressed: (){
                    Navigator.pop(context,false);
                  },
                      style: ElevatedButton.styleFrom(
                          minimumSize: Size(130, 40),
                          backgroundColor: Color(0xFF0461E5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          )
                      ),

                      child: Text("cancel",style: TextStyle(color: Colors.white),)
                  )
                ],
              )
            ],
          ),),
        );
      });

  }

  Future<void> handleLogout(BuildContext context)async{
    //remove token
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text("hi!$username",style: TextStyle(fontFamily: "Manrope",fontWeight: FontWeight.w800,),),
        actions: const [
          Icon(Icons.notification_add),
          SizedBox(width: 12),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Container(
        padding: EdgeInsets.all(24),
        color: Colors.grey[200],
        child: ListView(
          children: [
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16,horizontal: 20),
                child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text("My profile"),
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                  ),
                  ListTile(
                    leading: Icon(Icons.price_change),
                    title: Text("Change password"),
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text("Settings & Preferences"),
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                  ),
                  ListTile(
                    leading: Icon(Icons.support_agent),
                    title: Text("Support"),
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                  ),
                  ListTile(
                    leading:SizedBox(
                      width: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.text_snippet_rounded),
                          Icon(Icons.group_add),
                        ],
                      ),
                    ),

                    title: Text("About us"),
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                  ),
                ],
              ),)
            ),
            SizedBox(height: 10,),
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28)
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16,horizontal: 20),
                child:ListTile(
                  leading: Icon(Icons.logout),
                    title: Text("Logout"),
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () async {
                    final result=await showLogoutDialog(context);
                    if(result==true){
                      handleLogout(context);
                    }
                    else{
                      print("cancel");
                    }
                  },
                  ),
            ),
            ),

            Center(child: Text("Version 1.162",style:TextStyle(fontSize: 12,fontWeight: FontWeight.w200,fontFamily: "Manrope")))
          ],
        ),
      )
    );
  }
}
