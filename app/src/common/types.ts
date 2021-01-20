export enum EVENT_STEP {
  INIT = 1,
  QUERY,
  MODIFY,
  VIEW_HISTORY,
  VERIFY,
}

export interface DefaultEvent {
  step: EVENT_STEP;
}
