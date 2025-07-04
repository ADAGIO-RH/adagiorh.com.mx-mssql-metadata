USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Se utiliza cuando un candidato se convierte en empleado, mueve los expendientes digitales del candidato (Reclutamiento.tblExpedienteDigitalCandidato)      al del empleado (RH.tblExpedienteDigitalEmpleado)
                        Respetando las  reglas de los nombres para los archivos.
** Autor			:  Jose Vargas
** Email			:  jvargas@adagio.com.mx
** FechaCreacion	: 
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				    Comentario
------------------- -------------------     ------------------------------------------------------------
0000-00-00		    NombreCompleto		    ¿Qué cambió?
***************************************************************************************************/
CREATE PROCEDURE [Reclutamiento].[spMigrarExpedienteDigitalCandidatoEmpleado]  
(  
    @IDUsuario int = 0
    ,@IDCandidatoPlaza int  = 0    
    ,@ClaveEmpleado varchar(255)
    ,@IDEmpleado int = 0
)  
AS  
BEGIN  
  
    declare @IDCandidato int ;
    select @IDCandidato=IDCandidato From Reclutamiento.tblCandidatoPlaza where IDCandidatoPlaza=@IDCandidatoPlaza;

    DECLARE @tblExpedientesDigitalesCandidatoEmpleado TABLE (
        IDEmpleado int ,
        IDExpedienteDigital int ,
        NuevoNombreArchivo varchar(max),
        NuevoPathArchivo varchar(max),
        AnteriorNombreArchivo varchar(max),
        AnteriorPathArchivo varchar(max),
        ContentType varchar(255),
        Size INT ,
        FechaCreacion DATETIME,
        FechaVencimiento DATETIME,
        IDCandidato int
    );

    WITH ExpedientesDigitalesCandidato AS (
        SELECT 
            c.IDExpedienteDigital,        
            (SELECT TOP 1 item FROM app.Split(c.Name, '.') ORDER BY id DESC) AS Extension,
            (SELECT TOP 1 item FROM app.Split(REPLACE(c.Name, CAST(c.IDCandidato AS VARCHAR(255)) + '_' + ex.Codigo + '_', ''), '.') ORDER BY id ASC) AS NuevoNombreArchivo            
        FROM Reclutamiento.tblExpedienteDigitalCandidato c
        INNER JOIN RH.tblCatExpedientesDigitales ex ON ex.IDExpedienteDigital = c.IDExpedienteDigital
        WHERE c.IDCandidato = @IDCandidato and c.ArchivoMovido=0
    )    
    insert into @tblExpedientesDigitalesCandidatoEmpleado(IDEmpleado,IDExpedienteDigital,NuevoNombreArchivo,NuevoPathArchivo,AnteriorNombreArchivo,AnteriorPathArchivo,ContentType,Size,FechaCreacion,FechaVencimiento,IDCandidato)
    -- INSERT INTO RH.tblExpedienteDigitalEmpleado ([IDEmpleado], [IDExpedienteDigital],[Name],[ContentType],[PathFile],[Size],[FechaVencimiento],[FechaCreacion])
    -- OUTPUT INSERTED.IDExpedienteDigitalEmpleado INTO @tblIDsExpendientesNuevos    
    SELECT 
        @IDEmpleado,
        c.IDExpedienteDigital,
        UPPER(@ClaveEmpleado + '_' + ex.Codigo + '_' + f.NuevoNombreArchivo + '.' + f.Extension) AS FileName,
        'Docs/ExpDig/'+ @ClaveEmpleado +'/'+ UPPER(@ClaveEmpleado + '_' + ex.Codigo + '_' + f.NuevoNombreArchivo + '.' + f.Extension) AS FilePath,
        c.Name ,
        c.PathFile ,
        ContentType,        
        [Size],
        FechaVencimiento,
        FechaCreacion,
        @IDCandidato
    FROM Reclutamiento.tblExpedienteDigitalCandidato c
    INNER JOIN RH.tblCatExpedientesDigitales ex ON ex.IDExpedienteDigital = c.IDExpedienteDigital
    INNER JOIN ExpedientesDigitalesCandidato f ON f.IDExpedienteDigital = c.IDExpedienteDigital
    WHERE c.IDCandidato = @IDCandidato;

    UPDATE Reclutamiento.tblExpedienteDigitalCandidato set ArchivoMovido=1 WHERE IDCandidato=@IDCandidato        
    

    INSERT INTO RH.tblExpedienteDigitalEmpleado ([IDEmpleado], [IDExpedienteDigital],[Name],[ContentType],[PathFile],[Size],[FechaVencimiento],[FechaCreacion])
    select IDEmpleado,IDExpedienteDigital,NuevoNombreArchivo,ContentType,NuevoPathArchivo,[Size],FechaVencimiento,FechaCreacion from @tblExpedientesDigitalesCandidatoEmpleado     

    SELECT * From @tblExpedientesDigitalesCandidatoEmpleado    

END
GO
