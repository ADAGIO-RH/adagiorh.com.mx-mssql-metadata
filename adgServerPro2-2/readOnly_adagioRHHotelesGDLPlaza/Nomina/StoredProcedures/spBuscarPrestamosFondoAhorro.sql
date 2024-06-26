USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca préstamos de Fondo de Ahorro
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-05-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-10			Aneudy Abreu	Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									Seguridad.tblDetalleFiltrosEmpleadosUsuarios
***************************************************************************************************/
CREATE proc [Nomina].[spBuscarPrestamosFondoAhorro](
	 @IDPrestamoFondoAhorro	int = 0
	,@IDFondoAhorro			int	= 0
	,@IDEmpleado			int	= 0
	,@IDUsuario int
) as 
	
	select     
		P.IDPrestamo    
		,P.Codigo    
		,P.IDEmpleado    
		,E.ClaveEmpleado    
		,E.Nombre    
		,E.SegundoNombre    
		,E.Paterno    
		,E.Materno    
		,COALESCE(E.Paterno,'')+' '+COALESCE(E.Materno,'')+' '+COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'') AS NOMBRECOMPLETO    
		,P.IDTipoPrestamo    
		,TP.Descripcion as TipoPrestamo    
		,P.IDEstatusPrestamo    
		,EP.Descripcion as EstatusPrestamo    
		,P.MontoPrestamo    
		,P.Cuotas    
		,P.CantidadCuotas    
		,P.Descripcion    
		,P.FechaCreacion    
		,P.FechaInicioPago    
		,P.MontoPrestamo - isnull((Select Sum(MontoCuota) from Nomina.fnPagosPrestamo(P.IDPrestamo)),0)  as Balance   
		,ROW_NUMBER()Over(order by p.IDPrestamo) as ROWNUMBER   
	from [Nomina].[tblPrestamos] p    
	inner join [Nomina].[tblCatTiposPrestamo] TP    on p.IDTipoPrestamo = TP.IDTipoPrestamo
	inner join [Nomina].[tblPrestamosFondoAhorro] pfa on p.IDPrestamo = pfa.IDPrestamo --and pfa.IDEmpleado = @IDEmpleado   
	inner join [Nomina].[tblCatEstatusPrestamo] EP    on EP.IDEstatusPrestamo = p.IDEstatusPrestamo    
	inner join [RH].[tblEmpleados] e on P.IDEmpleado = e.IDEmpleado    
	inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario    
	where (pfa.IDFondoAhorro = @IDFondoAhorro)  
		and  (e.IDEmpleado = @IDEmpleado)
		and TP.IDTipoPrestamo = 6
	order by p.FechaCreacion desc
GO
