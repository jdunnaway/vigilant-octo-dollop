import { DefaultEvent } from './common/types';

export const handler = async (event: DefaultEvent): Promise<void> => {
  console.log(event.text);
};
