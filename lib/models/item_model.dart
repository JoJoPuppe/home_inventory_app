
class Item {
  final int itemId;
  final String name;
  final int? parentItemId;
  final String? comment;
  final String? imageSMPath;
  final String? imageLGPath;
  final int? labelId;
  final int? childrenCount;
  final DateTime? creationDate;
  final DateTime? lastUpdate;
  final List<String>? tags;

  Item({required this.itemId,
              required this.name,
              this.parentItemId,
              this.comment,
              this.imageSMPath,
              this.imageLGPath,
              this.childrenCount,
              this.creationDate,
              this.lastUpdate,
              this.labelId,
              this.tags,
              });

  Item.fromJson(Map<String, dynamic> json)
        : itemId = json['item_id'] as int,
          name = json['name'] as String,
          parentItemId = json['parent_item_id'] as int?,
          comment = json['comment'] as String?,
          childrenCount = json['children_count'] as int?,
          imageSMPath = json['image_sm_path'] as String?,
          labelId = json['label_id'] as int?,
          imageLGPath = json['image_lg_path'] as String?,
          creationDate = json['creation_date'] != null
            ? DateTime.tryParse(json['creation_date'])
            : null,
          lastUpdate = json['last_update'] != null
            ? DateTime.tryParse(json['last_update'])
            : null,
          tags = json['tags'] != null
            ? List<String>.from(json['tags'])
            : null;
}
    // item_id = Column(Integer, primary_key=True, index=True)
    // label_id = Column(Integer, ForeignKey('labels.label_id'))
    // parent_item_id = Column(Integer, ForeignKey('items.item_id'))
    // name = Column(String, nullable=False)
    // comment = Column(String)
    // image_path = Column(String)
    // creation_date = Column(DateTime(timezone=True), server_default=func.now())
    // last_update = Column(DateTime(timezone=True), onupdate=func.now())
    // tags = relationship("Tag", secondary=item_tags, back_populates="items")

