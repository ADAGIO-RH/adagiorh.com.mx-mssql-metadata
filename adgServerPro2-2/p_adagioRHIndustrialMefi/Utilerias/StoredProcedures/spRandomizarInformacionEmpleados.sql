USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************
** Descripción     : Procedimiento para la randomización de nombres de la base de datos EJECUTAR CON PRECAUCIÓN Y FUERA DE ENTORNOS PRODUCTIVOS
** Autor           : Javier Peña
** Email           : jpena@adagio.com.mx
** FechaCreacion   : 2024-03-01
** Parámetros      :
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd) Autor            Comentario
------------------ ---------------- ------------------------------------------------------------
EXEC [Utilerias].[spRandomizarInformacionEmpleados] 1 
***************************************************************************************************/

CREATE   PROCEDURE [Utilerias].[spRandomizarInformacionEmpleados] (
    @Confirmar bit = 0
) AS
BEGIN

IF(@Confirmar = 0)
BEGIN
    RAISERROR('LA EJECUCIÓN DE ESTE PROCEDIMIENTO ELIMINARÁ Y SUSTITUIRÁ DE FORMA DEFINITIVA LA INFORMACIÓN DE LOS EMPLEADOS EN LA BASE DE DATOS,¡¡¡NO EJECUTAR EN PRODUCCION!!!, EJECUTE ESTE PROCEDIMIENTO CON EL PARAMETRO 1 PARA CONFIRMAR DE ENTERADO', 16, 1);
    RETURN
END

BEGIN 
	BEGIN TRY
		BEGIN TRAN TransRandomEmp
                      DECLARE 
                     @FechaActual      NVARCHAR(20)
                    ,@NombreTablaResp  NVARCHAR(100)
                    ,@EsquemaTablaResp NVARCHAR(2) = 'BK'
                    ,@size             INT=0
                    ,@i                INT=0
                    ,@SEXO_MASCULINO   VARCHAR(10) = 'M'
                    ,@SEXO_FEMENINO    VARCHAR(10) = 'F'
                    ,@PASS_ADMIN       VARCHAR(MAX);

                    SELECT @PASS_ADMIN   = [Password] FROM Seguridad.tblUsuarios WHERE IDUsuario=1
                    SET @FechaActual     =  CONVERT(NVARCHAR(20), GETDATE(), 112)
                    SET @NombreTablaResp = 'tblEmpleadosNombresReales_' + @FechaActual


                    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA=@EsquemaTablaResp AND TABLE_NAME = @NombreTablaResp)
                    BEGIN    
                       EXEC('SELECT * INTO ' +@EsquemaTablaResp+'.'+@NombreTablaResp + ' FROM Rh.tblEmpleados')
                    END
                    
                    PRINT'NOMBRE RESPALDO DE TABLA EMPLEADOS: '+@EsquemaTablaResp+'.'+@NombreTablaResp

                    IF OBJECT_ID('tempdb..#tblEmpleadosRespaldoNombreRandom') IS NOT NULL drop table #tblEmpleadosRespaldoNombreRandom

                    SELECT * 
                    INTO #tblEmpleadosRespaldoNombreRandom
                    FROM RH.tblEmpleados


                    DECLARE @RandomValues TABLE (
                        IDEmpleado INT ,
                        Nombre VARCHAR(50),
                        SegundoNombre VARCHAR(50),
                        Paterno VARCHAR(50),
                        Materno VARCHAR(50),
                        RFC VARCHAR(13),    
                        IMSS VARCHAR(11),    
                        RW INT
                    )

                    DECLARE @RandomNombresBenificiarios TABLE (
                        IDFamiliarBenificiarioEmpleado INT,
                        NombreCompleto VARCHAR(MAX),
                        RW INT
                    )

                    DECLARE @RFCGenericos TABLE(
                        RFC VARCHAR(13)
                    )

                    INSERT INTO @RFCGenericos VALUES('FUNK671228PH6')
                    INSERT INTO @RFCGenericos VALUES('IAÑL750210963')
                    INSERT INTO @RFCGenericos VALUES('JUFA7608212V6')
                    INSERT INTO @RFCGenericos VALUES('KAHO641101B39')
                    INSERT INTO @RFCGenericos VALUES('KICR630120NX3')
                    INSERT INTO @RFCGenericos VALUES('MISC491214B86')
                    INSERT INTO @RFCGenericos VALUES('RAQÑ7701212M3')
                    INSERT INTO @RFCGenericos VALUES('WATM640917J45')
                    INSERT INTO @RFCGenericos VALUES('WERX631016S30')
                    INSERT INTO @RFCGenericos VALUES('XAMA620210DQ5')
                    INSERT INTO @RFCGenericos VALUES('XIQB891116QE4')
                    INSERT INTO @RFCGenericos VALUES('XOJI740919U48')



                    DELETE FROM @RandomValues        
                    SELECT  @size=count(IDEmpleado) FROM #tblEmpleadosRespaldoNombreRandom 
                    SET @i=0

                    WHILE @i<=@size
                    BEGIN

                        INSERT INTO @RandomValues (IDEmpleado, Nombre, SegundoNombre, Paterno, Materno,RFC,IMSS,RW)
                        SELECT * FROM
                        (
                            SELECT
                        	random.IDEmpleado
                           ,(SELECT TOP 1 Nombre        FROM #tblEmpleadosRespaldoNombreRandom WHERE Sexo=random.Sexo ORDER BY NEWID()) as Nombre
                           ,(SELECT TOP 1 SegundoNombre FROM #tblEmpleadosRespaldoNombreRandom WHERE Sexo=random.Sexo ORDER BY NEWID()) as SegundoNombre
                           ,(SELECT TOP 1 Paterno       FROM #tblEmpleadosRespaldoNombreRandom WHERE Sexo=random.Sexo ORDER BY NEWID()) as Paterno
                           ,(SELECT TOP 1 Materno       FROM #tblEmpleadosRespaldoNombreRandom WHERE Sexo=random.Sexo ORDER BY NEWID()) as Materno
                           ,(SELECT TOP 1 RFC           FROM @RFCGenericos ORDER BY NEWID())                                                as RFC
                           ,(SELECT TOP 1 LEFT(IMSS, 3) + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS VARCHAR(8)) FROM #tblEmpleadosRespaldoNombreRandom WHERE Sexo=random.Sexo ORDER BY NEWID()) as IMSS
                           ,ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNumber
                            FROM #tblEmpleadosRespaldoNombreRandom random                            
                        ) AS Datos
                        WHERE datos.RowNumber=@i

                        SET @i=@i+1

                    END

                    UPDATE RH.tblEmpleados
                    SET 
                        Nombre = RV.Nombre,
                        SegundoNombre = RV.SegundoNombre,
                        Paterno = RV.Paterno,
                        Materno = RV.Materno,
                        RFC     = RV.RFC,
                        IMSS    = RV.IMSS
                    FROM RH.tblEmpleados E
                    INNER JOIN (
                        SELECT 
                            IDEmpleado,
                            Nombre,
                            SegundoNombre,
                            Paterno,
                            Materno,
                            RFC,
                            IMSS
                        FROM @RandomValues
                    ) RV ON RV.IDEmpleado = E.IDEmpleado
                
                    DELETE FROM @RandomValues

                    UPDATE RH.tblEmpleados
                    SET  CURP  = RFC+LEFT(Nombre,1)+RIGHT(Nombre,1)+LEFT(Paterno,1)+RIGHT(Paterno,1)+LEFT(RFC,1)

                    IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblContactosUsuariosTiposNotificaciones' AND TABLE_SCHEMA = 'APP')
                    BEGIN
                        DELETE FROM APP.tblContactosUsuariosTiposNotificaciones
                    END

                    IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblContactosEmpleadosTiposNotificaciones' AND TABLE_SCHEMA = 'RH')
                    BEGIN
                        DELETE FROM RH.tblContactosEmpleadosTiposNotificaciones
                    END
                    DELETE  RH.tblContactoEmpleado
                    DELETE  RH.tblDireccionEmpleado
                                        
                    UPDATE RH.tblPagoEmpleado SET Cuenta=NULL,Sucursal=NULL,Interbancaria=NULL,Tarjeta=NULL,IDBancario=NULL

                    


                    EXEC RH.spSincronizarEmpleadosMaster

                    SELECT  @Size=count(IDFamiliarBenificiarioEmpleado) FROM RH.TblFamiliaresBenificiariosEmpleados
                    SET @i=0

                    WHILE @i<=@size
                    BEGIN

                        INSERT INTO @RandomNombresBenificiarios (IDFamiliarBenificiarioEmpleado,NombreCompleto,RW)
                        SELECT * FROM
                        (
                            SELECT
                        	familiar.IDFamiliarBenificiarioEmpleado
                           ,(SELECT TOP 1 M.NombreCompleto FROM RH.tblEmpleadosMaster M INNER JOIN RH.TBLEMPLEADOS E ON E.IDEmpleado=M.IDEmpleado WHERE E.Sexo=ISNULL(familiar.Sexo,@SEXO_FEMENINO) ORDER BY NEWID()) as NombreCompleto    
                           ,ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNumber
                            FROM rh.TblFamiliaresBenificiariosEmpleados as familiar                            
                        ) AS Datos
                        WHERE datos.RowNumber=@i

                        SET @i=@i+1

                    END

                    UPDATE RH.TblFamiliaresBenificiariosEmpleados
                    SET                         
                        NombreCompleto= RV.NombreCompleto
                       ,TelefonoMovil = null
                       ,TelefonoCelular = null                        
                    FROM RH.TblFamiliaresBenificiariosEmpleados B
                    INNER JOIN (
                        SELECT 
                            IDFamiliarBenificiarioEmpleado
                           ,NombreCompleto
                        FROM @RandomNombresBenificiarios
                    ) RV ON RV.IDFamiliarBenificiarioEmpleado = B.IDFamiliarBenificiarioEmpleado

                    
                    UPDATE Seguridad.tblUsuarios
                    SET Nombre=ISNULL(NULLIF(e.Nombre, '') + ' ' + NULLIF(e.SegundoNombre, ''), e.Nombre)
                       ,Apellido=ISNULL(NULLIF(e.Paterno, '') + ' ' + NULLIF(e.Materno, ''), e.Paterno)                       
                    FROM Seguridad.tblUsuarios U
                        INNER JOIN RH.tblEmpleados E
                        ON E.IDEmpleado=U.IDEmpleado
                    
                    UPDATE Seguridad.tblUsuarios
                    SET 
                        Email=NULL
                       ,[Password]=@PASS_ADMIN                                                               
                        


		COMMIT TRAN TransRandomEmp
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN TransRandomEmp
		select ERROR_MESSAGE() as Error
	END CATCH
END;
END
GO
