USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Demo].[spGenerarPeriodos] as 
	-- select * from Sat.tblCatPeriodicidadesPago
	--IDPeriodicidadPago Codigo     Descripcion
	-------------------- ---------- ------------------
	--1                  01         Diario
	--2                  02         Semanal
	--3                  03         Catorcenal
	--4                  04         Quincenal
	--5                  05         Mensual
	--6                  06         Bimestral
	--7                  07         Unidad obra
	--8                  08         Comisión
	--9                  09         Precio alzado
	--10                 10         Decenal
	--11                 99         Otra Periodicidad
	--12                 00         Anual
	
	declare @IDTipoNomina int
			,@IDPeriodicidadPago int
			,@Ejercicio int = datepart(year, getdate()) 
			,@fecha datetime = getdate()
			,@FechaInicioSemanal date 
			,@FechaInicioQuincenal date = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
	;

	DECLARE 
		@MostRecentMonday DATETIME = DATEDIFF(day, 0, @fecha - DATEDIFF(day, 0, @fecha) %7)
		,@MostRecentNextMonday DATETIME = DATEDIFF(day, -7, @fecha - DATEDIFF(day, -7, @fecha) %7)
	;

	if (datediff(day,@MostRecentMonday,@fecha) <  datediff(day,@fecha,@MostRecentNextMonday))
	begin
		set @FechaInicioSemanal = @MostRecentMonday
	end else
	begin
		set @FechaInicioSemanal = @MostRecentNextMonday
	end;

	select @IDTipoNomina = min(IDTipoNomina) from Nomina.tblCatTipoNomina

	while exists(select top 1 1 
				 from Nomina.tblCatTipoNomina 
				 where IDTipoNomina >= @IDTipoNomina)
	begin
		select @IDPeriodicidadPago = IDPeriodicidadPago
		from Nomina.tblCatTipoNomina
		where IDTipoNomina = @IDTipoNomina
	
		if (@IDPeriodicidadPago = 2)
		begin
			print 'Semanal'

			if not exists(select top 1 1 
						  from Nomina.tblCatPeriodos
						  where IDTipoNomina = @IDTipoNomina and Ejercicio = @Ejercicio)
			begin
				begin try
					exec [Nomina].[spGenerarPeriodos] 
					   @IDTipoNomina	   = @IDTipoNomina
					  ,@Ejercicio		   = @Ejercicio
					  ,@DiasDesfaceINC	   = 2
					  ,@PeriodosEstrictos  = 1
					  ,@FechaGenera		   = @FechaInicioSemanal
					  ,@General			   = 1
					  ,@Finiquito		   = 0
					  ,@Especial		   = 0
				end try
				begin catch
					exec Demo.spGetErrorInfo 
				end catch
			end;
		end else 
		if (@IDPeriodicidadPago = 4)
		begin
			if not exists(select top 1 1 
						  from Nomina.tblCatPeriodos
						  where IDTipoNomina = @IDTipoNomina and Ejercicio = @Ejercicio)
			begin
				begin try
					exec [Nomina].[spGenerarPeriodos] 
					   @IDTipoNomina	   = @IDTipoNomina
					  ,@Ejercicio		   = @Ejercicio
					  ,@DiasDesfaceINC	   = 2
					  ,@PeriodosEstrictos  = 1
					  ,@FechaGenera		   = @FechaInicioQuincenal
					  ,@General			   = 1
					  ,@Finiquito		   = 0
					  ,@Especial		   = 0
				end try
				begin catch
					exec Demo.spGetErrorInfo 
				end catch
			end;
		end; 
		
		--select @IDTipoNomina,@IDPeriodicidadPago
		select @IDTipoNomina = min(IDTipoNomina) from Nomina.tblCatTipoNomina where IDTipoNomina > @IDTipoNomina 
	end;
GO
