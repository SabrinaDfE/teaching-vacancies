import 'core-js/modules/es.weak-map';
import 'core-js/modules/es.weak-set';
import '@stimulus/polyfills';
import { Application } from '@hotwired/stimulus';

// view components
import FiltersController from '../../components/filters_component/filters_component';
import MapController from '../../components/map_component/map';
import VacancySelectorController from '../../components/vacancy_selector_component/vacancy_selector';

// js components
import AutocompleteController from './components/autocomplete/autocomplete';
import ClipboardController from './components/clipboard/clipboard';
import FormController from './components/form/form';
import LocationFinderController from './components/locationFinder/locationFinder';
import ManageQualificationsController from './components/manageQualifications/manageQualifications';
import PanelController from './components/panel/panel';
import TrackedLinkController from './components/trackedLink/trackedLink';
import UploadDocumentsController from './components/uploadDocuments/uploadDocuments';
import UtilsController from './components/utils';

const application = Application.start();

application.warnings = false;
application.debug = false;
window.Stimulus = application;

application.register('autocomplete', AutocompleteController);
application.register('clipboard', ClipboardController);
application.register('filters', FiltersController);
application.register('form', FormController);
application.register('location-finder', LocationFinderController);
application.register('manage-qualifications', ManageQualificationsController);
application.register('map', MapController);
application.register('panel', PanelController);
application.register('tracked-link', TrackedLinkController);
application.register('upload-documents', UploadDocumentsController);
application.register('utils', UtilsController);
application.register('vacancy-selector', VacancySelectorController);
