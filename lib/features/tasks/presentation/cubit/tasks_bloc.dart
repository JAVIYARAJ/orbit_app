import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit_app/features/tasks/domain/usecases/get_workstation_tasks_use_case.dart';
import 'package:orbit_app/features/tasks/presentation/cubit/tasks_state.dart';
import 'package:orbit_app/features/tasks/presentation/cubit/tasks_event.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  TasksBloc(this._getWorkstationTasks) : super(const TasksState()) {
    on<FetchTasksEvent>(_onFetchTasks);
    on<SearchTasksEvent>(_onSearchTasks);
    on<SetAssigneeFilterEvent>(_onSetAssigneeFilter);
    on<SetPriorityFilterEvent>(_onSetPriorityFilter);
    on<SetProjectFilterEvent>(_onSetProjectFilter);
    on<ToggleShowSubtasksEvent>(_onToggleShowSubtasks);
    on<TriggerExpandAllEvent>((event, emit) => emit(state.copyWith(expandAllSignal: state.expandAllSignal + 1)));
    on<TriggerCollapseAllEvent>((event, emit) => emit(state.copyWith(collapseAllSignal: state.collapseAllSignal + 1)));
  }

  final GetWorkstationTasksUseCase _getWorkstationTasks;

  Future<void> _onFetchTasks(FetchTasksEvent event, Emitter<TasksState> emit) async {
    emit(state.copyWith(status: TasksStatus.loading));
    final result = await _getWorkstationTasks(event.workstationId);
    result.match(
      (failure) => emit(state.copyWith(
        status: TasksStatus.error,
        errorMessage: failure.message,
      )),
      (data) => emit(state.copyWith(
        status: TasksStatus.loaded,
        tasks: data.tasks,
        statuses: data.statuses,
        members: data.members,
        priorities: data.priorities,
      )),
    );
  }

  void _onSearchTasks(SearchTasksEvent event, Emitter<TasksState> emit) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onSetAssigneeFilter(SetAssigneeFilterEvent event, Emitter<TasksState> emit) {
    if (event.assigneeId == null) {
      emit(state.copyWith(clearAssignee: true));
    } else {
      emit(state.copyWith(selectedAssigneeId: event.assigneeId));
    }
  }

  void _onSetPriorityFilter(SetPriorityFilterEvent event, Emitter<TasksState> emit) {
    if (event.priorityId == null) {
      emit(state.copyWith(clearPriority: true));
    } else {
      emit(state.copyWith(selectedPriorityId: event.priorityId));
    }
  }

  void _onToggleShowSubtasks(ToggleShowSubtasksEvent event, Emitter<TasksState> emit) {
    emit(state.copyWith(showSubtasks: event.showSubtasks));
  }

  void _onSetProjectFilter(SetProjectFilterEvent event, Emitter<TasksState> emit) {
    if (event.projectId == null) {
      emit(state.copyWith(clearProject: true));
    } else {
      emit(state.copyWith(selectedProjectId: event.projectId));
    }
  }
}
