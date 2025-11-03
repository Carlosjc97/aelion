const { queryRef, executeQuery, mutationRef, executeMutation, validateArgs } = require('firebase/data-connect');

const connectorConfig = {
  connector: 'courses',
  service: 'edaptia',
  location: 'us-east4'
};
exports.connectorConfig = connectorConfig;

const upsertLessonProgressRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'UpsertLessonProgress', inputVars);
}
upsertLessonProgressRef.operationName = 'UpsertLessonProgress';
exports.upsertLessonProgressRef = upsertLessonProgressRef;

exports.upsertLessonProgress = function upsertLessonProgress(dcOrVars, vars) {
  return executeMutation(upsertLessonProgressRef(dcOrVars, vars));
};

const getCourseCatalogRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetCourseCatalog', inputVars);
}
getCourseCatalogRef.operationName = 'GetCourseCatalog';
exports.getCourseCatalogRef = getCourseCatalogRef;

exports.getCourseCatalog = function getCourseCatalog(dcOrVars, vars) {
  return executeQuery(getCourseCatalogRef(dcOrVars, vars));
};

const getCourseOutlineRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetCourseOutline', inputVars);
}
getCourseOutlineRef.operationName = 'GetCourseOutline';
exports.getCourseOutlineRef = getCourseOutlineRef;

exports.getCourseOutline = function getCourseOutline(dcOrVars, vars) {
  return executeQuery(getCourseOutlineRef(dcOrVars, vars));
};
