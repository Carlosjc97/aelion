import { queryRef, executeQuery, mutationRef, executeMutation, validateArgs } from 'firebase/data-connect';

export const connectorConfig = {
  connector: 'courses',
  service: 'edaptia',
  location: 'us-east4'
};

export const upsertLessonProgressRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'UpsertLessonProgress', inputVars);
}
upsertLessonProgressRef.operationName = 'UpsertLessonProgress';

export function upsertLessonProgress(dcOrVars, vars) {
  return executeMutation(upsertLessonProgressRef(dcOrVars, vars));
}

export const getCourseCatalogRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetCourseCatalog', inputVars);
}
getCourseCatalogRef.operationName = 'GetCourseCatalog';

export function getCourseCatalog(dcOrVars, vars) {
  return executeQuery(getCourseCatalogRef(dcOrVars, vars));
}

export const getCourseOutlineRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetCourseOutline', inputVars);
}
getCourseOutlineRef.operationName = 'GetCourseOutline';

export function getCourseOutline(dcOrVars, vars) {
  return executeQuery(getCourseOutlineRef(dcOrVars, vars));
}

