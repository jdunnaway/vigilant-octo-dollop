import { DefaultEvent, EVENT_STEP } from './common/types';
import { QldbDriver, TransactionExecutor } from 'amazon-qldb-driver-nodejs';

import { getQldbDriver } from './vehicle_ledger/ConnectToLedger';
import {
  DRIVERS_LICENSE_TABLE_NAME,
  GOV_ID_INDEX_NAME,
  LICENSE_NUMBER_INDEX_NAME,
  LICENSE_PLATE_NUMBER_INDEX_NAME,
  PERSON_ID_INDEX_NAME,
  PERSON_TABLE_NAME,
  VEHICLE_REGISTRATION_TABLE_NAME,
  VEHICLE_TABLE_NAME,
  VIN_INDEX_NAME,
} from './vehicle_ledger/qldb/Constants';
import { error } from './vehicle_ledger/qldb/LogUtil';

import { createTable } from './vehicle_ledger/CreateTable';
import { createIndex } from './vehicle_ledger/CreateIndex';
import { updateAndInsertDocuments } from './vehicle_ledger/InsertDocument';
import { PERSON } from './vehicle_ledger/model/SampleData';
import { findVehiclesForOwner } from './vehicle_ledger/FindVehicles';

export const handler = async (event: DefaultEvent): Promise<void> => {
  console.log(event.step);

  const qldbDriver: QldbDriver = getQldbDriver();

  if (event.step == EVENT_STEP.INIT) {
    await initDatabase(qldbDriver);
  } else if (event.step == EVENT_STEP.QUERY) {
    await queryData(qldbDriver);
  }
};

async function initDatabase(driver: QldbDriver): Promise<void> {
  try {
    await driver.executeLambda(async (txn: TransactionExecutor) => {
      Promise.all([
        createTable(txn, VEHICLE_REGISTRATION_TABLE_NAME),
        createTable(txn, VEHICLE_TABLE_NAME),
        createTable(txn, PERSON_TABLE_NAME),
        createTable(txn, DRIVERS_LICENSE_TABLE_NAME),
      ]);
    });

    await driver.executeLambda(async (txn: TransactionExecutor) => {
      Promise.all([
        createIndex(txn, PERSON_TABLE_NAME, GOV_ID_INDEX_NAME),
        createIndex(txn, VEHICLE_TABLE_NAME, VIN_INDEX_NAME),
        createIndex(txn, VEHICLE_REGISTRATION_TABLE_NAME, VIN_INDEX_NAME),
        createIndex(
          txn,
          VEHICLE_REGISTRATION_TABLE_NAME,
          LICENSE_PLATE_NUMBER_INDEX_NAME
        ),
        createIndex(txn, DRIVERS_LICENSE_TABLE_NAME, PERSON_ID_INDEX_NAME),
        createIndex(txn, DRIVERS_LICENSE_TABLE_NAME, LICENSE_NUMBER_INDEX_NAME),
      ]);
    });

    await driver.executeLambda(async (txn: TransactionExecutor) => {
      await updateAndInsertDocuments(txn);
    });
  } catch (e) {
    error(`Unable to init tables and data: ${e}`);
  }
}

async function queryData(driver: QldbDriver): Promise<void> {
  try {
    await driver.executeLambda(async (txn: TransactionExecutor) => {
      await findVehiclesForOwner(txn, PERSON[0].GovId);
    });
  } catch (e) {
    error(`Unable to query data: ${e}`);
  }
}
