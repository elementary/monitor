public class Monitor.ContainerView : Gtk.Box {
    private ContainerManager container_manager;

    private ContainerSidebarView sidebar_view = new ContainerSidebarView ();
    private ContainerDetailedView detailed_view = new ContainerDetailedView ();

    private Gee.ArrayList<DockerContainer> containers;

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        hexpand = true;
    }

    public ContainerView () {

        container_manager = new ContainerManager ();

        sidebar_view.container_selected.connect(set_container_detailed_view);

        prepopulate ();

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        paned.pack1 (sidebar_view, true, false);
        paned.pack2 (detailed_view, true, false);

        add (paned);
    }

    private void set_container_detailed_view(DockerContainer container) {
        this.detailed_view.container = container;
    }

    private async void prepopulate () {
        this.containers = yield container_manager.list_containers ();

        foreach (var container in containers) {
            sidebar_view.insert (ref container);
        }
    }


    public void update () {
        foreach (var container in containers) {
                container.stats ();
        debug ("Container name: %s, memory used: %lld, perc: %f", container.name, container.mem_used, container.mem_percentage);
        }
        detailed_view.update();

        

        //  for (var i = 0; i < api_containers.length; i++) {
        //      var container = api_containers[i];

        //      debug("%s", container.name);
        //  }
    }

    //  private async void containers_load () throws ApiClientError {
    //      this.containers.clear ();

    //      // grouping containers into applications
    //      var api_containers = yield this.api_client.list_containers ();
    //      string[] projects = {};

    //      for (var i = 0; i < api_containers.length; i++) {
    //          var container = api_containers[i];

    //          if (container.label_project == null) {
    //              // single container
    //              this.containers.add (new DockerContainer.from_docker_api_container (container));
    //          } else {
    //              // if the container has already been processed
    //              if (container.label_project in projects) {
    //                  continue;
    //              }

                //  // create group
                //  var container_group = new DockerContainer ();

                //  var full_config_path = Path.build_filename (
                //      container.label_workdir,
                //      Path.get_basename (container.label_config)
                //  );

                //  container_group.id = full_config_path;
                //  container_group.name = container_group.format_name (container.label_project);
                //  container_group.image = "";
                //  container_group.type = DockerContainerType.GROUP;
                //  container_group.state = DockerContainerState.UNKNOWN;
                //  container_group.config_path = full_config_path;
                //  container_group.services = new Gee.ArrayList<DockerContainer> (DockerContainer.equal);

                //  // search for containers with the same project
                //  var is_all_running = true;
                //  var is_all_paused = true;
                //  var is_all_stopped = true;

                //  for (var j = i; j < api_containers.length; j++) {
                //      var service = api_containers[j];

                //      if (service.label_project != null && service.label_project == container.label_project) {
                //          var s = new DockerContainer.from_docker_api_container (service);
                //          s.name = s.format_name (service.label_service);

                //          is_all_running = is_all_running && s.state == DockerContainerState.RUNNING;
                //          is_all_paused = is_all_paused && s.state == DockerContainerState.PAUSED;
                //          is_all_stopped = is_all_stopped && s.state == DockerContainerState.STOPPED;

                //          container_group.services.add (s);
                //      }
                //  }

                //  // image
                //  string?[] services = {};

                //  foreach (var service in container_group.services) {
                //      services += service.name;
                //  }

                //  // state
                //  if (is_all_running) {
                //      container_group.state = DockerContainerState.RUNNING;
                //  }
                //  if (is_all_paused) {
                //      container_group.state = DockerContainerState.PAUSED;
    //              }
    //              if (is_all_stopped) {
    //                  container_group.state = DockerContainerState.STOPPED;
    //              }

    //              container_group.image = string.joinv (", ", services);

    //              // mark that the application has already been processed
    //              projects += container.label_project;

    //              // saving the container to the resulting array
    //              this.containers.add (container_group);
    //          }
    //      }

    //      this.notify_property ("containers");
    //  }

}
