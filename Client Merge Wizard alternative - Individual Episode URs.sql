-- Client Merge Script 27/2/2019 Mark Cosham
--
-- Notes:
-- If the URs overlap then only the UR will be changed (with # on the end to make it distict)
-- If the URs do not overlap then it will do a full merge of the cID and update the rest of TCM to match
-- Does not update text fields that contain the UR number such as the Description of the Budget (budget.bdName)
-- As this searches the SQL table definitions for all uniqueidentifiers it should survive new versions of TCM
-- It may be slower that strictly necessary as it will search some tables that won't have the Client ID in them
--
-- Update @MergeFrom to be the UR that you want to be removed
-- Update @MergeTo to be the UR that you want to merge into
--
-- Set @UPDATE
-- 0 = TEST ONLY (changes WILL NOT be applied)
-- 1 = UPDATE    (changes WILL be applied)
--

DECLARE @UPDATE int = 0
DECLARE @MergeFrom varchar(50)='8480445'
DECLARE @MergeTo varchar(50)='7964575'


BEGIN TRANSACTION
	SELECT epUR, epNo, cID, epRegistered, epCompleted FROM Episode where epUR like @MergeFrom+'%' OR  epUR like @MergeTo+'%' ORDER BY epUR, epNo

	DECLARE @Overlapping int
	-- Can only merge if there are not overlaping Episodes
	;
	with Clients (epUR, cID, epRegistered, epCompleted)
	AS
	(
		select epUR, cID, epRegistered, epCompleted
		from Episode E
		where epUR in (@MergeFrom, @MergeTo)
	)
	select @Overlapping=COUNT(*) --C1.epUR, C1.cID, (SELECT TOP 1 cID FROM Clients C WHERE C.epUR=C1.epUR ORDER BY epRegistered DESC, cID) AS LastClientID
	FROM Clients C1
	JOIN Clients C2 ON C1.cID<>C2.cID
	--group by C1.epUR, C1.cID
	WHERE (C1.epRegistered<=C2.epCompleted or C2.epCompleted IS NULL) AND (C2.epRegistered<=C1.epCompleted OR C1.epCompleted IS NULL)

	IF @Overlapping>0
	BEGIN
		print 'Change UR only'

		DECLARE @NewUR VARCHAR(50)=(SELECT max(epUR) from Episode where epUR=@MergeTo OR epUR like @MergeTo+'%')+'#'
		UPDATE Episode set epUR=@NewUR where epUR=@MergeFrom
	END
	ELSE
	BEGIN
		print 'Merge Clients'

		DECLARE @FromCID uniqueidentifier=(SELECT TOP 1 cID from Episode where epUR=@MergeFrom AND epRecent=1)
		DECLARE @ToCID uniqueidentifier=(SELECT TOP 1 cID from Episode where epUR=@MergeTo AND epRecent=1)

		DECLARE @SQL varchar(max), @Table varchar(max), @Column varchar(max)
		DECLARE @Message varchar(max)

		DECLARE db_cursor CURSOR FOR 
		select '['+C.TABLE_SCHEMA+'].['+C.TABLE_NAME+']', C.COLUMN_NAME
		from INFORMATION_SCHEMA.COLUMNS C
		JOIN INFORMATION_SCHEMA.TABLES T ON T.TABLE_NAME=C.TABLE_NAME AND TABLE_TYPE='BASE TABLE'
		where C.DATA_TYPE='UNIQUEIDENTIFIER'
		AND C.TABLE_NAME not in ('ClientData','Debtor')
		AND COLUMN_NAME NOT IN ('pgID', 'uID', 'grpID', 'evID', 'pID', 'serID', 'epID', 'rpID', 'psID', 'soID', 'sdID', 'crID', 'vtID', 'GroupID', 'itpID', 'siid',
			'PlannedServiceDeliveryID', 'ProgramID', 'pyeID', 'vtfID', 'abID', 'ccID', 'cilID', 'etrID', 'feeID', 'itrID', 'pinvID', 'ServiceDeliveryID', 'ServiceOccurrenceID',
			'WorkerID', 'bdID', 'crdID', 'ergID', 'mID', 'poiID', 'qID', 'ServiceDeliveryShiftID', 'wrpID', 'erID', 'expID', 'fgrpID', 'goalID', 'ipgoID', 'mealID', 'ncID',
			'ntID', 'poID', 'ProviderID', 'PurchaseInvoiceID', 'sdsID', 'ServiceID', 'StoID', 'svyID', 'tokID', 'trID', 'tsID', 'vID', 'wuID', 'acoID', 'alsID', 'bdmID',
			'bdtsID', 'brepID', 'cinvID', 'clfID', 'clmtID', 'csiID', 'ctID', 'EndEventID', 'eparID', 'epCareManager', 'evLinkedEventID', 'evProgramID', 'expiID', 'faID',
			'fcID', 'grpmID', 'gvtID', 'idID', 'itrsID', 'mcID', 'menuID', 'pabsID', 'peID', 'pfcID', 'pfID', 'phID', 'PlannedExpenseID', 'qgID', 'respGroupID', 'respID',
			'scrdID', 'sdFromLink', 'sdLinkedServiceDeliveryID', 'sdToLink', 'sfID', 'SourceServiceDeliveryShiftID', 'StartEventID', 'trIncomeType', 'trProgramID', 'vteID',
			'wtID', 'wslID', 'wrID', 'wpID', 'wgID', 'uGuid1', 'AccessAuditID', 'AccessWorkerID', 'EquipmentID', 'EventID', 'FacilityID', 'EpisodeID', 'ShiftID', 'aptID',
			'apExpenseClaimID', 'apGroupID', 'apID', 'apIncomeType', 'apPlannedExpenseID', 'apPlannedServiceID', 'apProgramID', 'apProviderID', 'apPurchaseInvoiceID',
			'grpID', 'evAssociateEvent', 'evContractID', 'evOriginalEventID'
		)
		ORDER BY C.TABLE_NAME, C.COLUMN_NAME
		OPEN db_cursor  
		FETCH NEXT FROM db_cursor INTO @Table, @Column
		WHILE @@FETCH_STATUS = 0  
		BEGIN
			set @SQL='UPDATE '+@Table+' SET ['+@Column+']='''+cast(@ToCID as char(36))+''' WHERE ['+@Column+']='''+cast(@FromCID as char(36))+''''

			SET @Message=@Table+' - '+@Column+' '+@SQL
			RAISERROR( @Message,0,1) WITH NOWAIT
			exec (@SQL)

			FETCH NEXT FROM db_cursor INTO @Table, @Column
		END

		CLOSE db_cursor
		DEALLOCATE db_cursor

		DELETE Debtor WHERE dID=@FromCID
		DELETE ClientData WHERE cID=@FromCID

		UPDATE E
		SET epUR=@MergeTo, epNo=R.R, epRecent=Recent
		from Episode E
		JOIN
		(
			SELECT epID, R, CASE WHEN R=MAX(R) OVER (Partition By cID) THEN 1 ELSE 0 END AS Recent
			FROM (
				SELECT epId, cID,
					ROW_NUMBER() OVER (PARTITION BY cID ORDER BY epRegistered) AS R
				FROM Episode
			) AS E
		) R ON R.epID=E.epID
		where cID=@ToCID
	END

SELECT epUR, epNo, cID, epRegistered, epCompleted FROM Episode where epUR like @MergeFrom+'%' OR  epUR like @MergeTo+'%' ORDER BY epUR, epNo

IF @UPDATE=0
	ROLLBACK
ELSE
	COMMIT
