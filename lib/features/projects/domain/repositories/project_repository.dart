import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/features/projects/domain/entities/project_entity.dart';

abstract interface class ProjectRepository {
  ResultFuture<List<ProjectEntity>> getWorkstationProjects(String workstationId);
  ResultFuture<ProjectEntity> getProjectDetail(String workstationId, String projectId);
  ResultFuture<Map<String, dynamic>> getGithubUser(String workstationId);
  ResultFuture<List<dynamic>> getGithubCommits(String workstationId, String owner, String repo);
  ResultFuture<void> deleteProject(String projectId);
  ResultFuture<void> deleteGithubRepo(String workstationId, String repoFullName);
  ResultFuture<ProjectEntity> createProject(String workstationId, Map<String, dynamic> projectData);
  ResultFuture<ProjectEntity> updateProject(String shortId, Map<String, dynamic> projectData);
}
