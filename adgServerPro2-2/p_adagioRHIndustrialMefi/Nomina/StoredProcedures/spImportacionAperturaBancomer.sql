USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Map de los empleados a los que se les va a importar cuenta y valida que tengan el Layout POR DEFINIR  
** Autor   : Joseph Román  
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
CREATE PROCEDURE [Nomina].[spImportacionAperturaBancomer]        
(        
 @dtImportacion [Nomina].[dtAperturaCuentaBancomerImportacion] READONLY      
 ,@IDUsuario int    
)        
AS        
BEGIN        
        
 select ROW_NUMBER()over(Order by ClaveEmpleado ASC) as RN        
  ,isnull((Select TOP 1 IDEmpleado from RH.tblEmpleadosMaster Where ClaveEmpleado = E.[ClaveEmpleado]),0) as [IDEmpleado]        
  ,E.[ClaveEmpleado]        
  ,isnull((Select TOP 1 NOMBRECOMPLETO from RH.tblEmpleadosMaster Where ClaveEmpleado = E.[ClaveEmpleado]),'') as [NombreCompleto]        
  ,Case when exists(select top 1 IDPagoEmpleado     
				 from RH.tblPagoEmpleado p   
				  inner join Nomina.tblLayoutPago lp  
				 on p.IDLayoutPago = lp.IDLayoutPago    
				  inner join Nomina.tblCatTiposLayout tl     
				   on lp.IDTipoLayout = tl.IDTipoLayout     
				  inner join RH.tblEmpleadosMaster m   
				  join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = m.IDEmpleado and dfe.IDUsuario = @IDUsuario   
				   on p.IDEmpleado = m.IDEmpleado    
				 where tl.TipoLayout = 'POR DEFINIR'     
				  and m.ClaveEmpleado = e.ClaveEmpleado )  THEN (select top 1 IDPagoEmpleado     
																 from RH.tblPagoEmpleado p   
																  inner join Nomina.tblLayoutPago lp  
																 on p.IDLayoutPago = lp.IDLayoutPago    
																  inner join Nomina.tblCatTiposLayout tl     
																   on lp.IDTipoLayout = tl.IDTipoLayout     
																  inner join RH.tblEmpleadosMaster m   
																  join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = m.IDEmpleado and dfe.IDUsuario = @IDUsuario   
																   on p.IDEmpleado = m.IDEmpleado    
																 where tl.TipoLayout = 'POR DEFINIR'     
																  and m.ClaveEmpleado = e.ClaveEmpleado )
																  ELSE 0 END as IDPagoEmpleado     
  ,isnull(e.Tarjeta,(select top 1 Tarjeta from RH.tblPagoEmpleado p inner join Nomina.tblLayoutPago lp on p.IDLayoutPago = lp.IDLayoutPago  inner join Nomina.tblCatTiposLayout tl   on lp.IDTipoLayout = tl.IDTipoLayout    where tl.TipoLayout = 'POR DEFINIR
' ))  as Tarjeta     
  ,isnull(e.Cuenta,(select top 1 Cuenta from RH.tblPagoEmpleado p inner join Nomina.tblLayoutPago lp on p.IDLayoutPago = lp.IDLayoutPago  inner join Nomina.tblCatTiposLayout tl   on lp.IDTipoLayout = tl.IDTipoLayout where tl.TipoLayout = 'POR DEFINIR' )) 
 as Cuenta     
  ,isnull(e.Interbancaria,(select top 1 Interbancaria from RH.tblPagoEmpleado p inner join Nomina.tblLayoutPago lp on p.IDLayoutPago = lp.IDLayoutPago  inner join Nomina.tblCatTiposLayout tl   on lp.IDTipoLayout = tl.IDTipoLayout where tl.TipoLayout = 'POR DEFINIR' )) as Interbancaria     
 from @dtImportacion E        
 WHERE isnull(E.ClaveEmpleado,'') <>''         
        
 --select 1        
END
GO
