USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Intranet].[spValidarSolicitudPrestamo](
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
		@NetoDisponible decimal(18,2),
		@SPValidaciones varchar(255)
	;
	-- Response
	--declare @resp as table (
	--	Mensaje varchar(500),
	--	Autorizado bit default 0
	--)


	SELECT @SPValidaciones = SPValidaciones FROM Intranet.tblCatTipoSolicitud with(nolock) where IDTipoSolicitud = 4

	IF(isnull(@SPValidaciones,'') <> '') 
	BEGIN
		exec sp_executesql N'exec @miSP @IDEmpleado,@IDTipoPrestamo,@MontoPrestamo,@FechaInicioPago,@IDFondoAhorro,@IDUsuario'                   
			,N' 	@IDEmpleado int
					,@IDTipoPrestamo int
					,@MontoPrestamo money
					,@FechaInicioPago date
					,@IDFondoAhorro int
					,@IDUsuario int
					,@miSP varchar(MAX)',                          
					@IDEmpleado = @IDEmpleado
					,@IDTipoPrestamo = @IDTipoPrestamo
					,@MontoPrestamo = @MontoPrestamo
					,@FechaInicioPago = @FechaInicioPago
					,@IDFondoAhorro = @IDFondoAhorro
					,@IDUsuario = @IDUsuario
					,@miSP = @SPValidaciones ; 
		RETURN;
	END
	ELSE
	BEGIN
		
		select 
		'Solicitud pre-autorizada' as Mensaje, 
		cast(1 as bit) as Autorizado
		RETURN;
	END
GO
