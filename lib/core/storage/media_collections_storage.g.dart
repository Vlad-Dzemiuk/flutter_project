// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_collections_storage.dart';

// ignore_for_file: type=lint
class $FavoritesTable extends Favorites
    with TableInfo<$FavoritesTable, FavoriteEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, data, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  FavoriteEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FavoritesTable createAlias(String alias) {
    return $FavoritesTable(attachedDatabase, alias);
  }
}

class FavoriteEntry extends DataClass implements Insertable<FavoriteEntry> {
  final String key;
  final String data;
  final int updatedAt;
  const FavoriteEntry({
    required this.key,
    required this.data,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['data'] = Variable<String>(data);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  FavoritesCompanion toCompanion(bool nullToAbsent) {
    return FavoritesCompanion(
      key: Value(key),
      data: Value(data),
      updatedAt: Value(updatedAt),
    );
  }

  factory FavoriteEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteEntry(
      key: serializer.fromJson<String>(json['key']),
      data: serializer.fromJson<String>(json['data']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'data': serializer.toJson<String>(data),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  FavoriteEntry copyWith({String? key, String? data, int? updatedAt}) =>
      FavoriteEntry(
        key: key ?? this.key,
        data: data ?? this.data,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  FavoriteEntry copyWithCompanion(FavoritesCompanion data) {
    return FavoriteEntry(
      key: data.key.present ? data.key.value : this.key,
      data: data.data.present ? data.data.value : this.data,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteEntry(')
          ..write('key: $key, ')
          ..write('data: $data, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, data, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteEntry &&
          other.key == this.key &&
          other.data == this.data &&
          other.updatedAt == this.updatedAt);
}

class FavoritesCompanion extends UpdateCompanion<FavoriteEntry> {
  final Value<String> key;
  final Value<String> data;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const FavoritesCompanion({
    this.key = const Value.absent(),
    this.data = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoritesCompanion.insert({
    required String key,
    required String data,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        data = Value(data),
        updatedAt = Value(updatedAt);
  static Insertable<FavoriteEntry> custom({
    Expression<String>? key,
    Expression<String>? data,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (data != null) 'data': data,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoritesCompanion copyWith({
    Value<String>? key,
    Value<String>? data,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return FavoritesCompanion(
      key: key ?? this.key,
      data: data ?? this.data,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesCompanion(')
          ..write('key: $key, ')
          ..write('data: $data, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WatchlistTable extends Watchlist
    with TableInfo<$WatchlistTable, WatchlistEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchlistTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, data, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watchlist';
  @override
  VerificationContext validateIntegrity(
    Insertable<WatchlistEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  WatchlistEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WatchlistEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WatchlistTable createAlias(String alias) {
    return $WatchlistTable(attachedDatabase, alias);
  }
}

class WatchlistEntry extends DataClass implements Insertable<WatchlistEntry> {
  final String key;
  final String data;
  final int updatedAt;
  const WatchlistEntry({
    required this.key,
    required this.data,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['data'] = Variable<String>(data);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  WatchlistCompanion toCompanion(bool nullToAbsent) {
    return WatchlistCompanion(
      key: Value(key),
      data: Value(data),
      updatedAt: Value(updatedAt),
    );
  }

  factory WatchlistEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WatchlistEntry(
      key: serializer.fromJson<String>(json['key']),
      data: serializer.fromJson<String>(json['data']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'data': serializer.toJson<String>(data),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  WatchlistEntry copyWith({String? key, String? data, int? updatedAt}) =>
      WatchlistEntry(
        key: key ?? this.key,
        data: data ?? this.data,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  WatchlistEntry copyWithCompanion(WatchlistCompanion data) {
    return WatchlistEntry(
      key: data.key.present ? data.key.value : this.key,
      data: data.data.present ? data.data.value : this.data,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WatchlistEntry(')
          ..write('key: $key, ')
          ..write('data: $data, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, data, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WatchlistEntry &&
          other.key == this.key &&
          other.data == this.data &&
          other.updatedAt == this.updatedAt);
}

class WatchlistCompanion extends UpdateCompanion<WatchlistEntry> {
  final Value<String> key;
  final Value<String> data;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const WatchlistCompanion({
    this.key = const Value.absent(),
    this.data = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WatchlistCompanion.insert({
    required String key,
    required String data,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        data = Value(data),
        updatedAt = Value(updatedAt);
  static Insertable<WatchlistEntry> custom({
    Expression<String>? key,
    Expression<String>? data,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (data != null) 'data': data,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WatchlistCompanion copyWith({
    Value<String>? key,
    Value<String>? data,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return WatchlistCompanion(
      key: key ?? this.key,
      data: data ?? this.data,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchlistCompanion(')
          ..write('key: $key, ')
          ..write('data: $data, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$MediaCollectionsDatabase extends GeneratedDatabase {
  _$MediaCollectionsDatabase(QueryExecutor e) : super(e);
  $MediaCollectionsDatabaseManager get managers =>
      $MediaCollectionsDatabaseManager(this);
  late final $FavoritesTable favorites = $FavoritesTable(this);
  late final $WatchlistTable watchlist = $WatchlistTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [favorites, watchlist];
}

typedef $$FavoritesTableCreateCompanionBuilder = FavoritesCompanion Function({
  required String key,
  required String data,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$FavoritesTableUpdateCompanionBuilder = FavoritesCompanion Function({
  Value<String> key,
  Value<String> data,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$FavoritesTableFilterComposer
    extends Composer<_$MediaCollectionsDatabase, $FavoritesTable> {
  $$FavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
        column: $table.key,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<String> get data => $composableBuilder(
        column: $table.data,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<int> get updatedAt => $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnFilters(column),
      );
}

class $$FavoritesTableOrderingComposer
    extends Composer<_$MediaCollectionsDatabase, $FavoritesTable> {
  $$FavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
        column: $table.key,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get data => $composableBuilder(
        column: $table.data,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnOrderings(column),
      );
}

class $$FavoritesTableAnnotationComposer
    extends Composer<_$MediaCollectionsDatabase, $FavoritesTable> {
  $$FavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FavoritesTableTableManager extends RootTableManager<
    _$MediaCollectionsDatabase,
    $FavoritesTable,
    FavoriteEntry,
    $$FavoritesTableFilterComposer,
    $$FavoritesTableOrderingComposer,
    $$FavoritesTableAnnotationComposer,
    $$FavoritesTableCreateCompanionBuilder,
    $$FavoritesTableUpdateCompanionBuilder,
    (
      FavoriteEntry,
      BaseReferences<_$MediaCollectionsDatabase, $FavoritesTable,
          FavoriteEntry>,
    ),
    FavoriteEntry,
    PrefetchHooks Function()> {
  $$FavoritesTableTableManager(
    _$MediaCollectionsDatabase db,
    $FavoritesTable table,
  ) : super(
          TableManagerState(
            db: db,
            table: table,
            createFilteringComposer: () =>
                $$FavoritesTableFilterComposer($db: db, $table: table),
            createOrderingComposer: () =>
                $$FavoritesTableOrderingComposer($db: db, $table: table),
            createComputedFieldComposer: () =>
                $$FavoritesTableAnnotationComposer($db: db, $table: table),
            updateCompanionCallback: ({
              Value<String> key = const Value.absent(),
              Value<String> data = const Value.absent(),
              Value<int> updatedAt = const Value.absent(),
              Value<int> rowid = const Value.absent(),
            }) =>
                FavoritesCompanion(
              key: key,
              data: data,
              updatedAt: updatedAt,
              rowid: rowid,
            ),
            createCompanionCallback: ({
              required String key,
              required String data,
              required int updatedAt,
              Value<int> rowid = const Value.absent(),
            }) =>
                FavoritesCompanion.insert(
              key: key,
              data: data,
              updatedAt: updatedAt,
              rowid: rowid,
            ),
            withReferenceMapper: (p0) => p0
                .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
                .toList(),
            prefetchHooksCallback: null,
          ),
        );
}

typedef $$FavoritesTableProcessedTableManager = ProcessedTableManager<
    _$MediaCollectionsDatabase,
    $FavoritesTable,
    FavoriteEntry,
    $$FavoritesTableFilterComposer,
    $$FavoritesTableOrderingComposer,
    $$FavoritesTableAnnotationComposer,
    $$FavoritesTableCreateCompanionBuilder,
    $$FavoritesTableUpdateCompanionBuilder,
    (
      FavoriteEntry,
      BaseReferences<_$MediaCollectionsDatabase, $FavoritesTable,
          FavoriteEntry>,
    ),
    FavoriteEntry,
    PrefetchHooks Function()>;
typedef $$WatchlistTableCreateCompanionBuilder = WatchlistCompanion Function({
  required String key,
  required String data,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$WatchlistTableUpdateCompanionBuilder = WatchlistCompanion Function({
  Value<String> key,
  Value<String> data,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$WatchlistTableFilterComposer
    extends Composer<_$MediaCollectionsDatabase, $WatchlistTable> {
  $$WatchlistTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
        column: $table.key,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<String> get data => $composableBuilder(
        column: $table.data,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<int> get updatedAt => $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnFilters(column),
      );
}

class $$WatchlistTableOrderingComposer
    extends Composer<_$MediaCollectionsDatabase, $WatchlistTable> {
  $$WatchlistTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
        column: $table.key,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get data => $composableBuilder(
        column: $table.data,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnOrderings(column),
      );
}

class $$WatchlistTableAnnotationComposer
    extends Composer<_$MediaCollectionsDatabase, $WatchlistTable> {
  $$WatchlistTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WatchlistTableTableManager extends RootTableManager<
    _$MediaCollectionsDatabase,
    $WatchlistTable,
    WatchlistEntry,
    $$WatchlistTableFilterComposer,
    $$WatchlistTableOrderingComposer,
    $$WatchlistTableAnnotationComposer,
    $$WatchlistTableCreateCompanionBuilder,
    $$WatchlistTableUpdateCompanionBuilder,
    (
      WatchlistEntry,
      BaseReferences<_$MediaCollectionsDatabase, $WatchlistTable,
          WatchlistEntry>,
    ),
    WatchlistEntry,
    PrefetchHooks Function()> {
  $$WatchlistTableTableManager(
    _$MediaCollectionsDatabase db,
    $WatchlistTable table,
  ) : super(
          TableManagerState(
            db: db,
            table: table,
            createFilteringComposer: () =>
                $$WatchlistTableFilterComposer($db: db, $table: table),
            createOrderingComposer: () =>
                $$WatchlistTableOrderingComposer($db: db, $table: table),
            createComputedFieldComposer: () =>
                $$WatchlistTableAnnotationComposer($db: db, $table: table),
            updateCompanionCallback: ({
              Value<String> key = const Value.absent(),
              Value<String> data = const Value.absent(),
              Value<int> updatedAt = const Value.absent(),
              Value<int> rowid = const Value.absent(),
            }) =>
                WatchlistCompanion(
              key: key,
              data: data,
              updatedAt: updatedAt,
              rowid: rowid,
            ),
            createCompanionCallback: ({
              required String key,
              required String data,
              required int updatedAt,
              Value<int> rowid = const Value.absent(),
            }) =>
                WatchlistCompanion.insert(
              key: key,
              data: data,
              updatedAt: updatedAt,
              rowid: rowid,
            ),
            withReferenceMapper: (p0) => p0
                .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
                .toList(),
            prefetchHooksCallback: null,
          ),
        );
}

typedef $$WatchlistTableProcessedTableManager = ProcessedTableManager<
    _$MediaCollectionsDatabase,
    $WatchlistTable,
    WatchlistEntry,
    $$WatchlistTableFilterComposer,
    $$WatchlistTableOrderingComposer,
    $$WatchlistTableAnnotationComposer,
    $$WatchlistTableCreateCompanionBuilder,
    $$WatchlistTableUpdateCompanionBuilder,
    (
      WatchlistEntry,
      BaseReferences<_$MediaCollectionsDatabase, $WatchlistTable,
          WatchlistEntry>,
    ),
    WatchlistEntry,
    PrefetchHooks Function()>;

class $MediaCollectionsDatabaseManager {
  final _$MediaCollectionsDatabase _db;
  $MediaCollectionsDatabaseManager(this._db);
  $$FavoritesTableTableManager get favorites =>
      $$FavoritesTableTableManager(_db, _db.favorites);
  $$WatchlistTableTableManager get watchlist =>
      $$WatchlistTableTableManager(_db, _db.watchlist);
}
