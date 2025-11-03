part of 'package:edaptia/features/modules/outline/module_outline_view.dart';

class OutlineSkeleton extends StatelessWidget {
  const OutlineSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(height: 20, width: 200),
                SizedBox(height: 12),
                Skeleton(height: 16, width: 160),
                SizedBox(height: 8),
                Skeleton(height: 16, width: double.infinity),
                SizedBox(height: 8),
                Skeleton(height: 16, width: double.infinity),
              ],
            ),
          ),
        );
      },
    );
  }
}
