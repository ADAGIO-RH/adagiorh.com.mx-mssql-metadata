USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Intranet].[spCoreValidarSolicitudPrestamo](
	@IDEmpleado int,
	@IDTipoPrestamo int, 
	@MontoPrestamo money = 0,
	@FechaInicioPago date,
	@IDFondoAhorro int = 0,
	@IDUsuario int
) as
	declare
		@Mensaje varchar(500),
		@Autorizado bit = 0,
		@NetoDisponible decimal(18,2)
	;
	-- Response
	--declare @resp as table (
	--	Mensaje varchar(500),
	--	Autorizado bit default 0
	--)

	declare @TotalesFondoAhorro as table (
		TotalAportacionesEmpresa		decimal(18,2),
		TotalAportacionesTrabajador		decimal(18,2),
		TotalDevolucionesEmpresa		decimal(18,2),
		TotalDevolucionesTrabajador		decimal(18,2),
		TotalRetirosEmpresa				decimal(18,2),
		TotalRetirosTrabajador			decimal(18,2),
		TotalAcumulado					decimal(18,2),
		TotalPrestamosFondoAhorro		decimal(18,2),
		TotalSaldoPendienteADescontar	decimal(18,2),
		NetoDisponible					decimal(18,2)
	)

	if (@IDTipoPrestamo = 6) 
	begin
		insert @TotalesFondoAhorro
		exec [Nomina].[spBuscarAcumuladoFondoAhorroPorEmpleado]
			@IDFondoAhorro	= @IDFondoAhorro
			,@IDEmpleado	= @IDEmpleado
			,@IDUsuario		= @IDUsuario
	
		select top 1 @NetoDisponible = ISNULL(NetoDisponible,0) - ISNULL(TotalPrestamosFondoAhorro,0)
		from @TotalesFondoAhorro

		if (@MontoPrestamo > @NetoDisponible)
		begin
			select
				'El monto solicitado ('+FORMAT(@MontoPrestamo, 'C')+ ') es mayor al monto disponible('+FORMAT(@NetoDisponible, 'C')+').' as Mensaje,
				cast(0 as bit) as Autorizado
			return
		end

		if exists(select top 1 1
				from [Nomina].[tblPrestamos] p    
					inner join [Nomina].[tblPrestamosFondoAhorro] pfa on pfa.IDPrestamo = p.IDPrestamo
					inner join [Nomina].[tblCatEstatusPrestamo] EP on EP.IDEstatusPrestamo = p.IDEstatusPrestamo    
				where (p.IDEmpleado = @IDEmpleado)
					and pfa.IDFondoAhorro = @IDFondoAhorro
					and DATEDIFF(month, p.FechaInicioPago, GETDATE()) < 6
					and p.IDEstatusPrestamo in (4) -- 4= SALDADO
				order by p.FechaInicioPago desc
		) 
		begin
			select top 1 @Mensaje =
				case when DATEDIFF(month, p.FechaInicioPago, GETDATE()) = 1 
					then 'Solo ha pasado ' +cast(DATEDIFF(month, p.FechaInicioPago, GETDATE()) as varchar)+' Mes de tu último préstamos SALDADO y tienen que pasar por lo menos 6 meses para solicitar otro.'
					else  'Solo has pasado ' +cast(DATEDIFF(month, p.FechaInicioPago, GETDATE()) as varchar)+' Meses de tu último préstamos SALDADO y tienen que pasar por lo menos 6 meses para solicitar otro.' end
			from [Nomina].[tblPrestamos] p    
					inner join [Nomina].[tblPrestamosFondoAhorro] pfa on pfa.IDPrestamo = p.IDPrestamo
					inner join [Nomina].[tblCatEstatusPrestamo] EP on EP.IDEstatusPrestamo = p.IDEstatusPrestamo    
				where (p.IDEmpleado = @IDEmpleado)
					and pfa.IDFondoAhorro = @IDFondoAhorro
					and DATEDIFF(month, p.FechaInicioPago, GETDATE()) < 6
					and p.IDEstatusPrestamo in (4) -- 4= SALDADO
				order by p.FechaInicioPago desc

			select 
				@Mensaje as Mensaje, 
				cast(0 as bit) as Autorizado
			return
		end
	end

	if exists(select top 1 1
				from [Nomina].[tblPrestamos] p    
					inner join [Nomina].[tblCatEstatusPrestamo] EP on EP.IDEstatusPrestamo = p.IDEstatusPrestamo    
				where (p.IDEmpleado = @IDEmpleado)
					and p.IDEstatusPrestamo in (2,1,3)
	) 
	begin
		select top 1 @Mensaje = 'Tienes un préstamos con el estatus de '+EP.Descripcion+'. Podrás solicituar otro cuando este esté SALDADO.'
		from [Nomina].[tblPrestamos] p    
			inner join [Nomina].[tblCatEstatusPrestamo] EP on EP.IDEstatusPrestamo = p.IDEstatusPrestamo    
		where (p.IDEmpleado = @IDEmpleado)
			and p.IDEstatusPrestamo in (2,1,3)

		select 
			@Mensaje as Mensaje, 
			cast(0 as bit) as Autorizado
		return
	end

	--if exists(select top 1 1
	--		from [Nomina].[tblPrestamos] p    
	--			inner join [Nomina].[tblCatEstatusPrestamo] EP on EP.IDEstatusPrestamo = p.IDEstatusPrestamo    
	--		where (p.IDEmpleado = @IDEmpleado)
	--			and DATEDIFF(month, p.FechaInicioPago, GETDATE()) < 6
	--			and p.IDTipoPrestamo <> 6 -- PRÉSTAMO FONDO DE AHORRO
	--			and p.IDEstatusPrestamo in (4) -- 4= SALDADO
	--		order by p.FechaInicioPago desc
	--) 
	--begin
	--	select top 1 @Mensaje =
	--		case when DATEDIFF(month, p.FechaInicioPago, GETDATE()) = 1 
	--			then 'Solo ha pasado ' +cast(DATEDIFF(month, p.FechaInicioPago, GETDATE()) as varchar)+' Mes de tu último préstamos SALDADO y tienen que pasar por lo menos 6 meses para solicitar otro.'
	--			else  'Solo has pasado ' +cast(DATEDIFF(month, p.FechaInicioPago, GETDATE()) as varchar)+' Meses de tu último préstamos SALDADO y tienen que pasar por lo menos 6 meses para solicitar otro.' end
	--	from [Nomina].[tblPrestamos] p    
	--			inner join [Nomina].[tblCatEstatusPrestamo] EP on EP.IDEstatusPrestamo = p.IDEstatusPrestamo    
	--		where (p.IDEmpleado = @IDEmpleado)
	--			and DATEDIFF(month, p.FechaInicioPago, GETDATE()) < 6
	--			and p.IDTipoPrestamo <> 6 -- PRÉSTAMO FONDO DE AHORRO
	--			and p.IDEstatusPrestamo in (4) -- 4= SALDADO
	--			order by p.FechaInicioPago desc
	--	select 
	--		@Mensaje as Mensaje, 
	--		cast(0 as bit) as Autorizado
	--	return
	--end

	select 
		'Solicitud pre-autorizada' as Mensaje, 
		cast(1 as bit) as Autorizado
GO
