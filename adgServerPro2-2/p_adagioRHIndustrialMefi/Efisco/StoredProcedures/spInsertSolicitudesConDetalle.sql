USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [Efisco].[spInsertSolicitudesConDetalle]  
(  
    @IDSolicitud int = 0  
   ,@IDEfisco VARCHAR(max)  
   ,@RFC NVARCHAR(13)  
   ,@TipoDocumento NVARCHAR(50)  
   ,@Estado NVARCHAR(50)  
   ,@TipoSolicitud NVARCHAR(50)  
   ,@Mensaje NVARCHAR(MAX)  
   ,@TotalArchivos INT  
   ,@IDUsuario int
   ,@FechaCreacion DATE
   ,@FechaInicial DATE
   ,@FechaFinal DATE
   ,@ReporteNominaEfisco Efisco.dtReporteNominaEfisco READONLY  
)  
AS  
BEGIN  

 DECLARE 
    @OldJSON Varchar(Max),
    @NewJSON Varchar(Max);



 IF(@IDSolicitud = 0)  
 BEGIN  

  INSERT INTO EFISCO.tblSolicitudesCreadas (IDEfisco, RFC, TipoDocumento, FechaCreacion, FechaInicial, FechaFinal, Estado, TipoSolicitud, Mensaje, TotalArchivos)  
  Select @IDEfisco, @RFC, @TipoDocumento, @FechaCreacion, @FechaInicial, @FechaFinal, @Estado, @TipoSolicitud, @Mensaje, @TotalArchivos  
    
  SET @IDSolicitud = @@IDENTITY  


  INSERT INTO EFISCO.tblDetallesSolicitudes (
     IDSolicitud
    ,[Version]
    ,Serie
    ,Folio
    ,NoCertificado
    ,Fecha
    ,Subtotal
    ,Descuento
    ,Total
    ,Moneda
    ,MetodoPago
    ,LugarExpedicion
    ,EmisorRFC
    ,EmisorNombre
    ,EmisorRegimenFiscal
    ,ReceptorRFC
    ,ReceptorNombre
    ,UUID
    ,FechaTimbrado
    ,RFCProvCertif
    ,SELLOCFD
    ,FechaPago
    ,FechaInicial
    ,FechaFinal
    ,NumDiasPagados
    ,TotalPagados
    ,TotalDeRecepciones
    ,TotalDeducciones
    ,TotalOtros
    ,RegistroPatronal
    ,NumEmpleado
    ,Estatus
    ,FechaCancelacion
  )
  Select 
     @IDSolicitud 
    ,[Version]
    ,Serie
    ,Folio
    ,NoCertificado
    ,Fecha
    ,Subtotal
    ,Descuento
    ,Total
    ,Moneda
    ,MetodoPago
    ,LugarExpedicion
    ,EmisorRFC
    ,EmisorNombre
    ,EmisorRegimenFiscal
    ,ReceptorRFC
    ,ReceptorNombre
    ,UUID
    ,FechaTimbrado
    ,RFCProvCertif
    ,SELLOCFD
    ,FechaPago
    ,FechaInicial
    ,FechaFinal
    ,NumDiasPagados
    ,TotalPagados
    ,TotalDeRecepciones
    ,TotalDeducciones
    ,TotalOtros
    ,RegistroPatronal
    ,NumEmpleado
    ,Estatus
    ,FechaCancelacion
 FROM @ReporteNominaEfisco

 END  
  
END
GO
