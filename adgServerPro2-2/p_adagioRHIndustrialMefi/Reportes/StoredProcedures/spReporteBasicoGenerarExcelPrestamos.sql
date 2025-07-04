USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************     
** Descripción  : Reporte básico que muestra los prestamos de un colaborador
** Autor   : Javier Peña
** Email   : jpena@adagio.com.mx
** FechaCreacion : 2023-06-19 
** Paremetros  :                  
    
** DataTypes Relacionados:     
****************************************************************************************************    
HISTORIAL DE CAMBIOS    
Fecha(yyyy-mm-dd) Autor   Comentario    
------------------- ------------------- ------------------------------------------------------------    

***************************************************************************************************/    
CREATE PROCEDURE [Reportes].[spReporteBasicoGenerarExcelPrestamos]  
(   
  @IDEmpleado int = 0    
 ,@EsFonacot bit = 0   
 ,@EsPersonal bit = 0   
 ,@dtFiltros Nomina.dtFiltrosRH readonly
 ,@IDUsuario int 
 
)    
AS    
BEGIN 


	select     		   
		 P.Codigo    		
		,P.FechaInicioPago as [Fecha]				
		,TP.Descripcion as [Tipo de Préstamo]    		
		,P.MontoPrestamo as [Monto Total]    
		,isnull(P.Intereses,0) as Intereses
		,(P.MontoPrestamo + isnull(P.Intereses,0))- isnull((Select Sum(MontoCuota) from Nomina.fnPagosPrestamo(P.IDPrestamo)),0)  as Saldo
		,P.Cuotas  as [Descuento]  
		,EP.Descripcion as [Estatus]  					
    from [Nomina].[tblPrestamos] p    
		inner join [Nomina].[tblCatTiposPrestamo] TP    
		on p.IDTipoPrestamo = TP.IDTipoPrestamo    
		inner join [Nomina].[tblCatEstatusPrestamo] EP    
		on EP.IDEstatusPrestamo = p.IDEstatusPrestamo    
		inner join [RH].[tblEmpleados] e    
		on P.IDEmpleado = e.IDEmpleado    
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario    
	where 
		((e.IDEmpleado = @IDEmpleado) or (@IDEmpleado = 0))   
		and TP.Descripcion in (select Descripcion 
								from [Nomina].[tblCatTiposPrestamo] 
								where (((@EsFonacot = 1) and (Descripcion = 'FONACOT')) 
									  OR((@EsFonacot = 0) AND (Descripcion <> 'FONACOT')))
									  and (((@EsPersonal = 1) and (Descripcion not in  ('PRÉSTAMO FONDO DE AHORRO','FONACOT')))
										OR ((@EsPersonal = 0))))  		
	order by p.FechaCreacion desc  
    
  
END
GO
