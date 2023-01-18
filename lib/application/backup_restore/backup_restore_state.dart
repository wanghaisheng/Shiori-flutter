part of 'backup_restore_bloc.dart';

@freezed
class BackupRestoreState with _$BackupRestoreState {
  const factory BackupRestoreState.loading() = _LoadingState;

  const factory BackupRestoreState.loaded() = _LoadedState;

  const factory BackupRestoreState.backupCreated({required CreateBackupResultModel result}) = _BackupCreatedState;
}
