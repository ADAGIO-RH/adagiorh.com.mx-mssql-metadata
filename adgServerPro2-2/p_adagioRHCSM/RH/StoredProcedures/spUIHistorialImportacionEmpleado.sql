USE [p_adagioRHCSM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spUIHistorialImportacionEmpleado]
(
	@IDTipoHistorial int =null,
	@dtHistorial [RH].[dtHistorialEmpleadoMap] READONLY
)
AS
BEGIN

	--1	Empresa
	--2	Registro Patronal
	--3	Departamento
	--4	Sucursal
	--5	Centro Costo
	--6	Area
	--7	Region
	--8	Division
	--9	Clasificacion Corporativa



	if OBJECT_ID('tempdb..#tblTempEmpleados') is not null
    drop table #tblTempEmpleados;

	select distinct IDEmpleado, ROW_NUMBER()over(order by IDEmpleado asc) RN
	into #tblTempEmpleados
	from @dtHistorial
	
	Declare @counter int = 1

	IF(@IDTipoHistorial = 1)
	BEGIN
	
		 MERGE RH.tblEmpresaEmpleado AS TARGET
		  USING @dtHistorial AS SOURCE
			 ON TARGET.IDEmpleado = SOURCE.IDEmpleado
				  and TARGET.FechaIni = SOURCE.FechaIni
			WHEN MATCHED Then
		  update
			 Set 				
				TARGET.IDEmpresa  = SOURCE.IDHistorial
			 WHEN NOT MATCHED BY TARGET THEN 
				INSERT(IDEmpleado,IDEmpresa,FechaIni,FechaFin)
				VALUES(SOURCE.IDEmpleado,SOURCE.IDHistorial,SOURCE.FechaIni,SOURCE.FechaFin);
		
		 if OBJECT_ID('tempdb..#tblTempHistorialEmp1') is not null
			drop table #tblTempHistorialEmp1;

		if OBJECT_ID('tempdb..#tblTempHistorialEmp2') is not null
			drop table #tblTempHistorialEmp2;

		WHILE(@counter <= (Select max(RN) from #tblTempEmpleados))
		BEGIN
			select *, ROW_NUMBER()over(order by FechaIni asc) as [Row]
			INTO #tblTempHistorialEmp1
			FROM RH.tblEmpresaEmpleado
			WHERE IDEmpleado = (Select IDEmpleado from #tblTempEmpleados where RN = @counter)
			order by FechaIni asc

			select 
			t1.IDEmpresaEmpleado
			,t1.IDEmpleado
			,t1.IDEmpresa
			,t1.FechaIni
			,FechaFin = case when t2.FechaIni is not null then dateadd(day,-1,t2.FechaIni) 
			else '9999-12-31' end 
			INTO #tblTempHistorialEmp2
			from #tblTempHistorialEmp1 t1
			   left join (select * 
					 from #tblTempHistorialEmp1) t2 on t1.[Row] = (t2.[Row]-1)

			update [TARGET]
			   set 
				  [TARGET].FechaFin = [SOURCE].FechaFin
			   FROM RH.tblEmpresaEmpleado as [TARGET]
				  join #tblTempHistorialEmp2 as [SOURCE] on [TARGET].IDEmpresaEmpleado = [SOURCE].IDEmpresaEmpleado	

			drop table #tblTempHistorialEmp1
			drop table #tblTempHistorialEmp2


		select @counter = @counter + 1;
		END

	END ELSE IF(@IDTipoHistorial = 2)
	BEGIN
		
		
			 MERGE RH.tblRegPatronalEmpleado AS TARGET
		  USING @dtHistorial AS SOURCE
			 ON TARGET.IDEmpleado = SOURCE.IDEmpleado
				  and TARGET.FechaIni = SOURCE.FechaIni
			WHEN MATCHED Then
		  update
			 Set 				
				TARGET.IDRegPatronal  = SOURCE.IDHistorial
			 WHEN NOT MATCHED BY TARGET THEN 
				INSERT(IDEmpleado,IDRegPatronal,FechaIni,FechaFin)
				VALUES(SOURCE.IDEmpleado,SOURCE.IDHistorial,SOURCE.FechaIni,SOURCE.FechaFin);
	
		if OBJECT_ID('tempdb..#tblTempHistorialRegP1') is not null
			drop table #tblTempHistorialRegP1;

		if OBJECT_ID('tempdb..#tblTempHistorialRegP2') is not null
			drop table #tblTempHistorialRegP2;

	WHILE(@counter <= (Select max(RN) from #tblTempEmpleados))
		BEGIN
			select *, ROW_NUMBER()over(order by FechaIni asc) as [Row]
			INTO #tblTempHistorialRegP1
			FROM RH.tblRegPatronalEmpleado
			WHERE IDEmpleado = (Select IDEmpleado from #tblTempEmpleados where RN = @counter)
			order by FechaIni asc

			select 
			t1.IDRegPatronalEmpleado
			,t1.IDEmpleado
			,t1.IDRegPatronal
			,t1.FechaIni
			,FechaFin = case when t2.FechaIni is not null then dateadd(day,-1,t2.FechaIni) 
			else '9999-12-31' end 
			INTO #tblTempHistorialRegP2
			from #tblTempHistorialRegP1 t1
			   left join (select * 
					 from #tblTempHistorialRegP1)  t2 on t1.[Row] = (t2.[Row]-1)

			update [TARGET]
			   set 
				  [TARGET].FechaFin = [SOURCE].FechaFin
			   FROM RH.tblRegPatronalEmpleado as [TARGET]
				  join #tblTempHistorialRegP2 as [SOURCE] on [TARGET].IDRegPatronalEmpleado = [SOURCE].IDRegPatronalEmpleado	

			drop table #tblTempHistorialRegP1
			drop table #tblTempHistorialRegP2


		select @counter = @counter + 1;
		END

	END ELSE IF(@IDTipoHistorial = 3)
	BEGIN
		
		 MERGE RH.tblDepartamentoEmpleado AS TARGET
		  USING @dtHistorial AS SOURCE
			 ON TARGET.IDEmpleado = SOURCE.IDEmpleado
				  and TARGET.FechaIni = SOURCE.FechaIni
			WHEN MATCHED Then
		  update
			 Set 				
				TARGET.IDDepartamento  = SOURCE.IDHistorial
			 WHEN NOT MATCHED BY TARGET THEN 
				INSERT(IDEmpleado,IDDepartamento,FechaIni,FechaFin)
				VALUES(SOURCE.IDEmpleado,SOURCE.IDHistorial,SOURCE.FechaIni,SOURCE.FechaFin);
				
		if OBJECT_ID('tempdb..#tblTempHistorialDep1') is not null
			drop table #tblTempHistorialDep1;

		if OBJECT_ID('tempdb..#tblTempHistorialDep2') is not null
			drop table #tblTempHistorialDep2;

	WHILE(@counter <= (Select max(RN) from #tblTempEmpleados))
		BEGIN
			select *, ROW_NUMBER()over(order by FechaIni asc) as [Row]
			INTO #tblTempHistorialDep1
			FROM RH.tblDepartamentoEmpleado
			WHERE IDEmpleado = (Select IDEmpleado from #tblTempEmpleados where RN = @counter)
			order by FechaIni asc

			select 
			t1.IDDepartamentoEmpleado
			,t1.IDEmpleado
			,t1.IDDepartamento
			,t1.FechaIni
			,FechaFin = case when t2.FechaIni is not null then dateadd(day,-1,t2.FechaIni) 
			else '9999-12-31' end 
			INTO #tblTempHistorialDep2
			from #tblTempHistorialDep1 t1
			   left join (select * 
					 from #tblTempHistorialDep1) t2 on t1.[Row] = (t2.[Row]-1)

			update [TARGET]
			   set 
				  [TARGET].FechaFin = [SOURCE].FechaFin
			   FROM RH.tblDepartamentoEmpleado as [TARGET]
				  join #tblTempHistorialDep2 as [SOURCE] on [TARGET].IDDepartamentoEmpleado = [SOURCE].IDDepartamentoEmpleado	

			drop table #tblTempHistorialDep1
			drop table #tblTempHistorialDep2


		select @counter = @counter + 1;
		END


	END ELSE IF(@IDTipoHistorial = 4)
	BEGIN
		
		MERGE RH.tblSucursalEmpleado AS TARGET
		  USING @dtHistorial AS SOURCE
			 ON TARGET.IDEmpleado = SOURCE.IDEmpleado
				  and TARGET.FechaIni = SOURCE.FechaIni
			WHEN MATCHED Then
		  update
			 Set 				
				TARGET.IDSucursal  = SOURCE.IDHistorial
			 WHEN NOT MATCHED BY TARGET THEN 
				INSERT(IDEmpleado,IDSucursal,FechaIni,FechaFin)
				VALUES(SOURCE.IDEmpleado,SOURCE.IDHistorial,SOURCE.FechaIni,SOURCE.FechaFin);

				if OBJECT_ID('tempdb..#tblTempHistorialSuc1') is not null
			drop table #tblTempHistorialSuc1;

		if OBJECT_ID('tempdb..#tblTempHistorialSuc2') is not null
			drop table #tblTempHistorialSuc2;

	WHILE(@counter <= (Select max(RN) from #tblTempEmpleados))
		BEGIN
			select *, ROW_NUMBER()over(order by FechaIni asc) as [Row]
			INTO #tblTempHistorialSuc1
			FROM RH.tblSucursalEmpleado
			WHERE IDEmpleado = (Select IDEmpleado from #tblTempEmpleados where RN = @counter)
			order by FechaIni asc

			select 
			t1.IDSucursalEmpleado
			,t1.IDEmpleado
			,t1.IDSucursal
			,t1.FechaIni
			,FechaFin = case when t2.FechaIni is not null then dateadd(day,-1,t2.FechaIni) 
			else '9999-12-31' end 
			INTO #tblTempHistorialSuc2
			from #tblTempHistorialSuc1 t1
			   left join (select * 
					 from #tblTempHistorialSuc1) t2 on t1.[Row] = (t2.[Row]-1)

			update [TARGET]
			   set 
				  [TARGET].FechaFin = [SOURCE].FechaFin
			   FROM RH.tblSucursalEmpleado as [TARGET]
				  join #tblTempHistorialSuc2 as [SOURCE] on [TARGET].IDSucursalEmpleado = [SOURCE].IDSucursalEmpleado	

			drop table #tblTempHistorialSuc1
			drop table #tblTempHistorialSuc2


		select @counter = @counter + 1;
		END

	END ELSE IF(@IDTipoHistorial = 5)
	BEGIN
		
		MERGE RH.tblCentroCostoEmpleado AS TARGET
		  USING @dtHistorial AS SOURCE
			 ON TARGET.IDEmpleado = SOURCE.IDEmpleado
				  and TARGET.FechaIni = SOURCE.FechaIni
			WHEN MATCHED Then
		  update
			 Set 				
				TARGET.IDCentroCosto  = SOURCE.IDHistorial
			 WHEN NOT MATCHED BY TARGET THEN 
				INSERT(IDEmpleado,IDCentroCosto,FechaIni,FechaFin)
				VALUES(SOURCE.IDEmpleado,SOURCE.IDHistorial,SOURCE.FechaIni,SOURCE.FechaFin);

		if OBJECT_ID('tempdb..#tblTempHistorialCC1') is not null
			drop table #tblTempHistorialCC1;

		if OBJECT_ID('tempdb..#tblTempHistorialCC2') is not null
			drop table #tblTempHistorialCC2;

	WHILE(@counter <= (Select max(RN) from #tblTempEmpleados))
		BEGIN
			select *, ROW_NUMBER()over(order by FechaIni asc) as [Row]
			INTO #tblTempHistorialCC1
			FROM RH.tblCentroCostoEmpleado
			WHERE IDEmpleado = (Select IDEmpleado from #tblTempEmpleados where RN = @counter)
			order by FechaIni asc

			select 
			t1.IDCentroCostoEmpleado
			,t1.IDEmpleado
			,t1.IDCentroCosto
			,t1.FechaIni
			,FechaFin = case when t2.FechaIni is not null then dateadd(day,-1,t2.FechaIni) 
			else '9999-12-31' end 
			INTO #tblTempHistorialCC2
			from #tblTempHistorialCC1 t1
			   left join (select * 
					 from #tblTempHistorialCC1) t2 on t1.[Row] = (t2.[Row]-1)

			update [TARGET]
			   set 
				  [TARGET].FechaFin = [SOURCE].FechaFin
			   FROM RH.tblCentroCostoEmpleado as [TARGET]
				  join #tblTempHistorialCC2 as [SOURCE] on [TARGET].IDCentroCostoEmpleado = [SOURCE].IDCentroCostoEmpleado	

			drop table #tblTempHistorialCC1
			drop table #tblTempHistorialCC2


		select @counter = @counter + 1;
		END
	END ELSE IF(@IDTipoHistorial = 6)
	BEGIN
		
		
		MERGE RH.tblAreaEmpleado AS TARGET
		  USING @dtHistorial AS SOURCE
			 ON TARGET.IDEmpleado = SOURCE.IDEmpleado
				  and TARGET.FechaIni = SOURCE.FechaIni
			WHEN MATCHED Then
		  update
			 Set 				
				TARGET.IDArea  = SOURCE.IDHistorial
			 WHEN NOT MATCHED BY TARGET THEN 
				INSERT(IDEmpleado,IDArea,FechaIni,FechaFin)
				VALUES(SOURCE.IDEmpleado,SOURCE.IDHistorial,SOURCE.FechaIni,SOURCE.FechaFin);
		
		if OBJECT_ID('tempdb..#tblTempHistorialAR1') is not null
			drop table #tblTempHistorialAR1;

		if OBJECT_ID('tempdb..#tblTempHistorialAR2') is not null
			drop table #tblTempHistorialAR2;

	WHILE(@counter <= (Select max(RN) from #tblTempEmpleados))
		BEGIN
			select *, ROW_NUMBER()over(order by FechaIni asc) as [Row]
			INTO #tblTempHistorialAR1
			FROM RH.tblAreaEmpleado
			WHERE IDEmpleado = (Select IDEmpleado from #tblTempEmpleados where RN = @counter)
			order by FechaIni asc

			select 
			t1.IDAreaEmpleado
			,t1.IDEmpleado
			,t1.IDArea
			,t1.FechaIni
			,FechaFin = case when t2.FechaIni is not null then dateadd(day,-1,t2.FechaIni) 
			else '9999-12-31' end 
			INTO #tblTempHistorialAR2
			from #tblTempHistorialAR1 t1
			   left join (select * 
					 from #tblTempHistorialAR1) t2 on t1.[Row] = (t2.[Row]-1)

			update [TARGET]
			   set 
				  [TARGET].FechaFin = [SOURCE].FechaFin
			   FROM RH.tblAreaEmpleado as [TARGET]
				  join #tblTempHistorialAR2 as [SOURCE] on [TARGET].IDAreaEmpleado = [SOURCE].IDAreaEmpleado	

			drop table #tblTempHistorialAR1
			drop table #tblTempHistorialAR2


		select @counter = @counter + 1;
		END

	END ELSE IF(@IDTipoHistorial = 7)
	BEGIN
		
		MERGE RH.tblRegionEmpleado AS TARGET
		  USING @dtHistorial AS SOURCE
			 ON TARGET.IDEmpleado = SOURCE.IDEmpleado
				  and TARGET.FechaIni = SOURCE.FechaIni
			WHEN MATCHED Then
		  update
			 Set 				
				TARGET.IDRegion  = SOURCE.IDHistorial
			 WHEN NOT MATCHED BY TARGET THEN 
				INSERT(IDEmpleado,IDRegion,FechaIni,FechaFin)
				VALUES(SOURCE.IDEmpleado,SOURCE.IDHistorial,SOURCE.FechaIni,SOURCE.FechaFin);

		if OBJECT_ID('tempdb..#tblTempHistorialREG1') is not null
			drop table #tblTempHistorialREG1;

		if OBJECT_ID('tempdb..#tblTempHistorialREG2') is not null
			drop table #tblTempHistorialREG2;

	WHILE(@counter <= (Select max(RN) from #tblTempEmpleados))
		BEGIN
			select *, ROW_NUMBER()over(order by FechaIni asc) as [Row]
			INTO #tblTempHistorialREG1
			FROM RH.tblRegionEmpleado
			WHERE IDEmpleado = (Select IDEmpleado from #tblTempEmpleados where RN = @counter)
			order by FechaIni asc

			select 
			t1.IDRegionEmpleado
			,t1.IDEmpleado
			,t1.IDRegion
			,t1.FechaIni
			,FechaFin = case when t2.FechaIni is not null then dateadd(day,-1,t2.FechaIni) 
			else '9999-12-31' end 
			INTO #tblTempHistorialREG2
			from #tblTempHistorialREG1 t1
			   left join (select * 
					 from #tblTempHistorialREG1) t2 on t1.[Row] = (t2.[Row]-1)

			update [TARGET]
			   set 
				  [TARGET].FechaFin = [SOURCE].FechaFin
			   FROM RH.tblRegionEmpleado as [TARGET]
				  join #tblTempHistorialREG2 as [SOURCE] on [TARGET].IDRegionEmpleado = [SOURCE].IDRegionEmpleado	

			drop table #tblTempHistorialREG1
			drop table #tblTempHistorialREG2


		select @counter = @counter + 1;
		END

	END ELSE IF(@IDTipoHistorial = 8)
	BEGIN
		
			MERGE RH.tblDivisionEmpleado AS TARGET
		  USING @dtHistorial AS SOURCE
			 ON TARGET.IDEmpleado = SOURCE.IDEmpleado
				  and TARGET.FechaIni = SOURCE.FechaIni
			WHEN MATCHED Then
		  update
			 Set 				
				TARGET.IDDivision  = SOURCE.IDHistorial
			 WHEN NOT MATCHED BY TARGET THEN 
				INSERT(IDEmpleado,IDDivision,FechaIni,FechaFin)
				VALUES(SOURCE.IDEmpleado,SOURCE.IDHistorial,SOURCE.FechaIni,SOURCE.FechaFin);

		if OBJECT_ID('tempdb..#tblTempHistorialDiv1') is not null
			drop table #tblTempHistorialDiv1;

		if OBJECT_ID('tempdb..#tblTempHistorialDiv2') is not null
			drop table #tblTempHistorialDiv2;

	WHILE(@counter <= (Select max(RN) from #tblTempEmpleados))
		BEGIN
			select *, ROW_NUMBER()over(order by FechaIni asc) as [Row]
			INTO #tblTempHistorialDiv1
			FROM RH.tblDivisionEmpleado
			WHERE IDEmpleado = (Select IDEmpleado from #tblTempEmpleados where RN = @counter)
			order by FechaIni asc

			select 
			t1.IDDivisionEmpleado
			,t1.IDEmpleado
			,t1.IDDivision
			,t1.FechaIni
			,FechaFin = case when t2.FechaIni is not null then dateadd(day,-1,t2.FechaIni) 
			else '9999-12-31' end 
			INTO #tblTempHistorialDiv2
			from #tblTempHistorialDiv1 t1
			   left join (select * 
					 from #tblTempHistorialDiv1) t2 on t1.[Row] = (t2.[Row]-1)

			update [TARGET]
			   set 
				  [TARGET].FechaFin = [SOURCE].FechaFin
			   FROM RH.tblDivisionEmpleado as [TARGET]
				  join #tblTempHistorialDiv2 as [SOURCE] on [TARGET].IDDivisionEmpleado = [SOURCE].IDDivisionEmpleado	

			drop table #tblTempHistorialDiv1
			drop table #tblTempHistorialDiv2


		select @counter = @counter + 1;
		END

	END ELSE IF(@IDTipoHistorial = 9)
	BEGIN
		
			MERGE RH.tblClasificacionCorporativaEmpleado AS TARGET
		  USING @dtHistorial AS SOURCE
			 ON TARGET.IDEmpleado = SOURCE.IDEmpleado
				  and TARGET.FechaIni = SOURCE.FechaIni
			WHEN MATCHED Then
		  update
			 Set 				
				TARGET.IDClasificacionCorporativa  = SOURCE.IDHistorial
			 WHEN NOT MATCHED BY TARGET THEN 
				INSERT(IDEmpleado,IDClasificacionCorporativa,FechaIni,FechaFin)
				VALUES(SOURCE.IDEmpleado,SOURCE.IDHistorial,SOURCE.FechaIni,SOURCE.FechaFin);

				if OBJECT_ID('tempdb..#tblTempHistorialCorp1') is not null
			drop table #tblTempHistorialCorp1;

		if OBJECT_ID('tempdb..#tblTempHistorialCorp2') is not null
			drop table #tblTempHistorialCorp2;

	WHILE(@counter <= (Select max(RN) from #tblTempEmpleados))
		BEGIN
			select *, ROW_NUMBER()over(order by FechaIni asc) as [Row]
			INTO #tblTempHistorialCorp1
			FROM RH.tblClasificacionCorporativaEmpleado
			WHERE IDEmpleado = (Select IDEmpleado from #tblTempEmpleados where RN = @counter)
			order by FechaIni asc

			select 
			t1.IDClasificacionCorporativaEmpleado
			,t1.IDEmpleado
			,t1.IDClasificacionCorporativa
			,t1.FechaIni
			,FechaFin = case when t2.FechaIni is not null then dateadd(day,-1,t2.FechaIni) 
			else '9999-12-31' end 
			INTO #tblTempHistorialCorp2
			from #tblTempHistorialCorp1 t1
			   left join (select * 
					 from #tblTempHistorialCorp1) t2 on t1.[Row] = (t2.[Row]-1)

			update [TARGET]
			   set 
				  [TARGET].FechaFin = [SOURCE].FechaFin
			   FROM RH.tblClasificacionCorporativaEmpleado as [TARGET]
				  join #tblTempHistorialCorp2 as [SOURCE] on [TARGET].IDClasificacionCorporativaEmpleado = [SOURCE].IDClasificacionCorporativaEmpleado	

			drop table #tblTempHistorialCorp1
			drop table #tblTempHistorialCorp2


		select @counter = @counter + 1;
		END
	END
	
	
	
   declare @tran int 
   set @tran = @@TRANCOUNT
   if(@tran = 0)
   BEGIN

		DECLARE @IDEmpleado int,
		@counterMaster int = 1

		WHILE(@counterMaster <= (Select max(RN) from #tblTempEmpleados))
		BEGIN
			select @IDEmpleado from #tblTempEmpleados where RN = @counterMaster	

			exec [RH].[spMapSincronizarEmpleadosMaster] @IDEmpleado = @IDEmpleado  

		select @counterMaster = @counterMaster + 1;
		END


   END




END
GO
