import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/widgets/logout.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'full_profile_pic.dart';
import 'viewmodel.dart';
//import 'viewmodel/account_viewmodel.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AccountViewModel>();
    final user = vm.user;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          'Account',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body:
          user == null
              ? Center(child: Text("Not logged in"))
              : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Stack(
                      children: [
                      GestureDetector(
  onTap: () {
    final url = user.photoURL;
    if (url != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullScreenImageViewer(
            imageUrl: url,
            tag: 'profile-pic', // optional
          ),
        ),
      );
    }
  },
  child: Hero(
    tag: 'profile-pic',
    child: CircleAvatar(
      radius: 40,
      backgroundImage:
          user.photoURL != null ? NetworkImage(user.photoURL!) : null,
      child: user.photoURL == null
          ? const Icon(Icons.person, size: 40)
          : null,
    ),
  ),
),

                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                          onTap: () => _showPhotoOptions(context),

                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.displayName ?? 'No Name',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      user.email ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Information',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _tile(
                      context,
                      'Change Password',
                      Icons.lock,
                      onTap: () => context.push('/change-password'),
                    ),
                    _tile(
                      context,
                      'Change Username',
                      Icons.person,
                      onTap: () => context.push('/change-username'),
                    ),
                    _tile(
                      context,
                      'Change Email',
                      Icons.email,
                      onTap: () => context.push('/change-email'),
                    ),
                    _tile(
                      context,
                      'Report Issue',
                      Icons.report,
                      onTap: () => context.push('/report-issue'),
                    ),
                    const Spacer(),
                 GestureDetector(
  onTap: () {
    showLogoutConfirmation(
      context,
      () => vm.logout(),
    );
  },
  child: Text(
    'Logout',
    style: GoogleFonts.poppins(
      color: Colors.red,
      fontWeight: FontWeight.w600,
    ),
  ),
),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
    );
  }
Widget _tile(
  BuildContext context,
  String title,
  IconData icon, {
  VoidCallback? onTap,
  bool disabled = false,
}) {
  return ListTile(
    minTileHeight: 50,
    dense: true,
    contentPadding: EdgeInsets.zero,
    title: Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: disabled ? Colors.grey : null,
      ),
    ),
    trailing: const Icon(Icons.chevron_right),
    leading: Icon(icon, color: disabled ? Colors.grey : null),
    onTap: disabled
        ? () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Not Available'),
                content: const Text(
                  'Password and Email changes are disabled for Google Sign-in accounts.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/link-account');
                    },
                    child: const Text('Link Account'),
                  ),
                ],
              ),
            );
          }
        : onTap,
  );
}

  Widget _til(
    BuildContext context,
    String title,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right),
      leading: Icon(icon),
      onTap: onTap,
    );
  }

void _showPhotoOptions(BuildContext context) {
  final vm = Provider.of<AccountViewModel>(context, listen: false);
  final picker = ImagePicker();

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take a photo'),
            onTap: () async {
              final picked = await picker.pickImage(source: ImageSource.camera);
              if (picked != null) {
                final bytes = await picked.readAsBytes();
                await vm.updateProfilePicture(bytes);
              }
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from gallery'),
            onTap: () async {
              final picked = await picker.pickImage(source: ImageSource.gallery);
              if (picked != null) {
                final bytes = await picked.readAsBytes();
                await vm.updateProfilePicture(bytes);
              }
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}


}
