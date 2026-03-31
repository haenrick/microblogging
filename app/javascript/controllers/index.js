import { application } from "controllers/application"
import ToggleController from "controllers/toggle_controller"
import PostFormController from "controllers/post_form_controller"
import ThemeController from "controllers/theme_controller"
import PushNotificationsController from "controllers/push_notifications_controller"

application.register("toggle", ToggleController)
application.register("post-form", PostFormController)
application.register("theme", ThemeController)
application.register("push-notifications", PushNotificationsController)
