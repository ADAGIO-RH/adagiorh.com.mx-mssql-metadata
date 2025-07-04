USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc Demo.spBuscarColaboradoresAMover(
	@IDTipoNominaFrom int
	,@IDTipoNominaTo int
	,@Qty int
	,@AsignarNuevaClave bit = 0
) as

	declare @NuevaClave varchar(20)
	,@IDEmpleado int = 0 	
	,@FechaAntiguedad date
	,@SalarioDiario decimal(18,2)
	,@SalarioDiarioReal decimal(18,2)
	,@SalarioIntegrado decimal(18,2)
	,@SalarioVariable decimal(18,2)
	,@IDClienteTo int
		,@dtEmpleados RH.dtEmpleados
	;

	declare @tempNuevaClave table (
		Clave varchar(20)
	)

	select @IDClienteTo = IDCliente 
	from Nomina.tblCatTipoNomina
	where IDTipoNomina = @IDTipoNominaTo

	insert @dtEmpleados
	select * from RH.tblEmpleadosMaster where IDTipoNomina = @IDTipoNominaFrom

	;With updateData as (
		select IDEmpleado, ROW_NUMBER()OVER(order by ClaveEmpleado desc) as RN
		from @dtEmpleados
	)

	update e 
		set e.RowNumber = u.RN
	from @dtEmpleados e
		join updateData u on e.IDEmpleado = u.IDEmpleado

	delete from @dtEmpleados 
	where RowNumber > @Qty

	--select @IDEmpleado = MIN(IDEmpleado) from @dtEmpleados
	--while exists(select top 1 1 from @dtEmpleados where IDEmpleado >= @IDEmpleado)
	--begin
	--	select @FechaAntiguedad = FechaAntiguedad from @dtEmpleados where IDEmpleado = @IDEmpleado

	--	delete from RH.tblTipoNominaEmpleado where IDEmpleado = @IDEmpleado

	--	exec RH.spUITipoNominaEmpleado @IDTipoNominaEmpleado = 0
	--								  ,@IDEmpleado = @IDEmpleado
	--								  ,@IDTipoNomina = @IDTipoNominaTo
	--								  ,@FechaIni = @FechaAntiguedad
	--								  ,@FechaFin = '2019-09-04'

	--	if (@AsignarNuevaClave = 1)
	--	begin
	--		delete from @tempNuevaClave;

	--		INSERT @tempNuevaClave
	--		exec [RH].[spGenerarClaveEmpleado] @IDClienteTo,1

	--		select top 1 @NuevaClave = Clave from @tempNuevaClave

	--		update RH.tblEmpleados
	--			set ClaveEmpleado = @NuevaClave
	--		where IDEmpleado = @IDEmpleado
	--	end;

	--	print @IDEmpleado
	--	select @IDEmpleado = MIN(IDEmpleado) from @dtEmpleados where IDEmpleado > @IDEmpleado
	--end;

	select ClaveEmpleado
	from @dtEmpleados 
	order by ClaveEmpleado
GO
