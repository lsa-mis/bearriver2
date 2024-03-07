// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from "./application"

import HelloController from "./hello_controller"
application.register("hello", HelloController)

import RegistrationController from "./registration_controller"
application.register("registration", RegistrationController)

import WorkshopSelectionController from "./workshop_selection_controller"
application.register("workshop-selection", WorkshopSelectionController)
