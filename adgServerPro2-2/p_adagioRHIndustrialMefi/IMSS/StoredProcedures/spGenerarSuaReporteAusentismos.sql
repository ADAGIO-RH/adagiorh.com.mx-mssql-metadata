USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IMSS].[spGenerarSuaReporteAusentismos]  
(  
@FechaIni date = '1900-01-01',                
 @Fechafin date = '9999-12-31',                
 @AfectaIDSE bit = 0,  
 @FechaIDSE date = '9999-12-31',     
  @dtFiltros [Nomina].[dtFiltrosRH] READONLY,
  @IDUsuario int

)  
AS  
BEGIN  
  declare @IDRegPatronal int
	 , @dtEmpleados RH.dtEmpleados;

	select top 1 @IDRegPatronal = item from app.Split((select top 1 value from @dtFiltros where Catalogo = 'RegPatronales'),',')

   insert into @dtEmpleados      
   exec [RH].[spBuscarEmpleados] @FechaIni = @FechaIni, @Fechafin= @Fechafin, @dtFiltros = @dtFiltros, @IDUsuario= @IDUsuario      
    

 select   
  [App].[fnAddString](11,ISNULL(rp.RegistroPatronal,''),'',2) -- REGISTRO PATRONAL IMSS  
     -- + [App].[fnAddString](2,ISNULL(' ',''),'',2)  
   + [App].[fnAddString](11,ISNULL(e.IMSS,''),'',2) -- NUMERO DE SEGURIDAD SOCIAL  
  --  + [App].[fnAddString](2,ISNULL(' ',''),'',2)  
   + [App].[fnAddString](2,'11','',2) -- Tipo de Movimiento  
  + [App].[fnAddString](8,ISNULL(FORMAT(IE.Fecha, 'ddMMyyyy'),''),'0',2) -- FECHA DE MOVIMIENTO  
    
  -- + [App].[fnAddString](8,'',' ',2) -- FOLIO INCAPACIDAD  
   + [App].[fnAddString](8,'',' ',1) -- Filler  
   + [App].[fnAddString](2,'01',' ',1) -- DIAS INCAPACIDAD  
   + [App].[fnAddString](7,'0','0',1) -- SALARIO DIARIO INTEGRADO   
 from @dtEmpleados e  
  inner join rh.tblCatRegPatronal rp  
   on e.IDRegPatronal = rp.IDRegPatronal  
  inner join Asistencia.tblIncidenciaEmpleado IE  
   on e.IDEmpleado = IE.IDEmpleado  
   and IE.Fecha BETWEEN @FechaIni and @Fechafin  
   and IE.IDIncidencia IN (SELECT IDIncidencia FROM Asistencia.tblCatIncidencias where ISNULL(AfectaSUA,0) = 1) 
   and IE.Autorizado = 1
 END
GO
