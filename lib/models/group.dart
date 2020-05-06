import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String groupId;
  final String name;
  final String coverPhoto;
  final dynamic members;
  final dynamic joinRequests;
  final String privacy;
  final String ownerId;
  final String visibility;
  final int membersCount;
  final String category;
  final String location;
  final String requestApproval;
  final String postCreators;
  final bool postApproval;
  final dynamic groupRules;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Group({
    this.groupId,
    this.name,
    this.coverPhoto,
    this.members,
    this.joinRequests,
    this.privacy,
    this.ownerId,
    this.visibility,
    this.membersCount,
    this.category,
    this.location,
    this.requestApproval,
    this.postCreators,
    this.postApproval,
    this.groupRules,
    this.createdAt,
    this.updatedAt
  });

  factory Group.fromDocument(DocumentSnapshot doc) {
    return Group(
      groupId: doc['groupId'],
      name: doc['name'],
      coverPhoto: doc['coverPhoto'],
      members: doc['members'],
      privacy: doc['privacy'],
      ownerId: doc['ownerId'],
      visibility: doc['visibility'],
      membersCount: doc['membersCount'],
      joinRequests: doc['joinRequests'],
      category: doc['category'],
      location: doc['location'],
      requestApproval: doc['requestApproval'],
      postCreators: doc['postCreators'],
      postApproval: doc['postApproval'],
      groupRules: doc['groupRules'],
      createdAt: doc['createdAt'],
      updatedAt: doc['updatedAt']
    );
  }
}
