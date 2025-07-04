USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc Nomina.spBuscarRetiros(
	@IDRetiroFondoAhorro int				 
	,@IDEmpleado int					
	,@IDUsuario int	
) as

	select 
		 rfa.IDRetiroFondoAhorro as ID
		,rfa.IDEmpleado
		,0 IDConcepto  
		,'' Codigo
		, p.IDPeriodo
		, p.FechaFinPago as Fecha
		, p.ClavePeriodo as Periodo
		,isnull(rfa.MontoEmpresa,0) as MontoEmpresa
		,isnull(rfa.MontoTrabajador,0) as MontoTrabajador
		,isnull(rfa.MontoEmpresa,0)+isnull(rfa.MontoTrabajador,0) as Importe
		,'' Descripcion
		,Estatus = case when isnull(P.Cerrado,0) = 0 then 'Pendiente' else 'Aplicado' end
		,cast(0 as bit) as Pagado
	from Nomina.tblRetirosFondoAhorro rfa
		Inner join Nomina.tblCatPeriodos P on rfa.IDPeriodo = P.IDPeriodo
	where rfa.IDEmpleado = @IDEmpleado and rfa.IDRetiroFondoAhorro = @IDRetiroFondoAhorro
GO
