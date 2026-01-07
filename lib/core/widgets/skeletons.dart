import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Skeleton extends StatelessWidget {
  const Skeleton({super.key, this.height, this.width, this.borderRadius = 8});

  final double? height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade900,
      highlightColor: Colors.grey.shade800,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class FeedSkeleton extends StatelessWidget {
  const FeedSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: 3, // Simulate a few items
      itemBuilder: (context, index) {
        return const Stack(
          fit: StackFit.expand,
          children: [
            // Video placeholder
            Skeleton(),

            // Interaction buttons placeholder
            Positioned(
              right: 16,
              bottom: 100,
              child: Column(
                children: [
                  Skeleton(width: 40, height: 40, borderRadius: 20),
                  SizedBox(height: 20),
                  Skeleton(width: 40, height: 40, borderRadius: 20),
                  SizedBox(height: 20),
                  Skeleton(width: 40, height: 40, borderRadius: 20),
                ],
              ),
            ),

            // Text info placeholder
            Positioned(
              left: 16,
              bottom: 40,
              right: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(width: 150, height: 20),
                  SizedBox(height: 10),
                  Skeleton(width: 250, height: 16),
                  SizedBox(height: 6),
                  Skeleton(width: 200, height: 16),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class ActivitySkeleton extends StatelessWidget {
  const ActivitySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              Skeleton(width: 48, height: 48, borderRadius: 24),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 120, height: 16),
                    SizedBox(height: 8),
                    Skeleton(width: 180, height: 14),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Skeleton(width: 40, height: 40, borderRadius: 8),
            ],
          ),
        );
      },
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Skeleton(width: 92, height: 92, borderRadius: 46),
              SizedBox(height: 16),
              Skeleton(width: 150, height: 24),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Skeleton(width: 60, height: 40),
                  SizedBox(width: 20),
                  Skeleton(width: 60, height: 40),
                  SizedBox(width: 20),
                  Skeleton(width: 60, height: 40),
                ],
              ),
            ],
          ),
        ),

        // Tab bar placeholder
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Skeleton(width: double.infinity, height: 48),
        ),

        // Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(2),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 0.8,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              return const Skeleton(borderRadius: 0);
            },
          ),
        ),
      ],
    );
  }
}

class ExploreSkeleton extends StatelessWidget {
  const ExploreSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          const Skeleton(width: double.infinity, height: 48, borderRadius: 12),
          const SizedBox(height: 24),

          // Suggested accounts horizontal
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                5,
                (index) => const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Skeleton(width: 140, height: 180, borderRadius: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Trending tags chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                6,
                (index) => const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Skeleton(width: 80, height: 32, borderRadius: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => const Skeleton(borderRadius: 12),
          ),
        ],
      ),
    );
  }
}
