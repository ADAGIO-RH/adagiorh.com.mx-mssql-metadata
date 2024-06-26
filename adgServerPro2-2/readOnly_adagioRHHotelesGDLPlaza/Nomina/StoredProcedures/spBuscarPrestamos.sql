USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************     
** Descripción  : Busca préstamos    
** Autor   : Jose Roman    
** Email   : jose.roman@adagio.com.mx    
** FechaCreacion : 2019-01-01    
** Paremetros  :                  
    
** DataTypes Relacionados:     
****************************************************************************************************    
HISTORIAL DE CAMBIOS    
Fecha(yyyy-mm-dd) Autor   Comentario    
------------------- ------------------- ------------------------------------------------------------    
2019-05-10   Aneudy Abreu Se agregó el parámetro @IDUsuario y el JOIN a la tabla de     
         Seguridad.tblDetalleFiltrosEmpleadosUsuarios    
***************************************************************************************************/    
CREATE PROCEDURE [Nomina].[spBuscarPrestamos]  --@IDUsuario = 1, @EsFonacot = 0  
(   
  @IDEmpleado int = 0   
 ,@IDPrestamo int = 0   
 ,@EsFonacot bit = 0   
 ,@IDUsuario int    
)    
AS    
BEGIN    
    
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
		,(P.MontoPrestamo + isnull(P.Intereses,0))- isnull((Select Sum(MontoCuota) from Nomina.fnPagosPrestamo(P.IDPrestamo)),0)  as Balance   
		,isnull(P.Intereses,0) as Intereses
		,ROW_NUMBER()Over(order by p.IDPrestamo) as ROWNUMBER   
	from [Nomina].[tblPrestamos] p    
		inner join [Nomina].[tblCatTiposPrestamo] TP    
		on p.IDTipoPrestamo = TP.IDTipoPrestamo    
		inner join [Nomina].[tblCatEstatusPrestamo] EP    
		on EP.IDEstatusPrestamo = p.IDEstatusPrestamo    
		inner join [RH].[tblEmpleados] e    
		on P.IDEmpleado = e.IDEmpleado    
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario    
	where ((p.IDPrestamo = @IDPrestamo) or (@IDPrestamo = 0))  
		and  ((e.IDEmpleado = @IDEmpleado) or (@IDEmpleado = 0))   
		and TP.Descripcion in (select Descripcion from [Nomina].[tblCatTiposPrestamo] where ((@EsFonacot = 1) and (Descripcion = 'FONACOT')) OR((@EsFonacot = 0) AND (Descripcion <> 'FONACOT')) )  
		and (p.IDTipoPrestamo <> 6)
	order by p.FechaCreacion desc  
  
END
GO
