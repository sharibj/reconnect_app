import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingWidget extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const LoadingWidget({
    super.key,
    this.height = 20,
    this.width,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class LoadingListTile extends StatelessWidget {
  const LoadingListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const LoadingWidget(
              height: 50,
              width: 50,
              borderRadius: 25,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LoadingWidget(height: 16, width: double.infinity),
                  const SizedBox(height: 8),
                  LoadingWidget(
                    height: 14,
                    width: MediaQuery.of(context).size.width * 0.6,
                  ),
                  const SizedBox(height: 8),
                  LoadingWidget(
                    height: 12,
                    width: MediaQuery.of(context).size.width * 0.4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingCard extends StatelessWidget {
  const LoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LoadingWidget(height: 24, width: double.infinity),
            const SizedBox(height: 16),
            const LoadingWidget(height: 16, width: double.infinity),
            const SizedBox(height: 8),
            LoadingWidget(
              height: 16,
              width: MediaQuery.of(context).size.width * 0.7,
            ),
            const SizedBox(height: 8),
            LoadingWidget(
              height: 16,
              width: MediaQuery.of(context).size.width * 0.5,
            ),
          ],
        ),
      ),
    );
  }
}

class ContactLoadingGrid extends StatelessWidget {
  const ContactLoadingGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const LoadingCard(),
    );
  }
}

class InteractionLoadingList extends StatelessWidget {
  const InteractionLoadingList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => const LoadingListTile(),
    );
  }
}