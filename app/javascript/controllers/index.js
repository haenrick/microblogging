import { application } from "controllers/application"
import ToggleController from "controllers/toggle_controller"
import PostFormController from "controllers/post_form_controller"

application.register("toggle", ToggleController)
application.register("post-form", PostFormController)
