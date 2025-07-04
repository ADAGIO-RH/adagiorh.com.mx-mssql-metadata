USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Procedure para guardar y actualizar las Brigadas>
** Autor			: <Jose Rafael Roman Gil>
** Email			: <jose.roman@adagio.com.mx>
** FechaCreacion	: <08/06/2018>
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				    Comentario
------------------- -------------------     ------------------------------------------------------------
0000-00-00		    NombreCompleto		    ¿Qué cambió?
***************************************************************************************************/

CREATE PROCEDURE [RH].[spUICatBrigadas]
(
	@IDBrigada int = 0,
	@Descripcion Varchar(MAX),
	@IDUsuario int,
    @Traduccion nvarchar(max)
)
AS
BEGIN
	set @Descripcion = UPPER(@Descripcion)

	 DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max); 

	IF(@IDBrigada = 0)
	BEGIN
		INSERT INTO RH.tblCatBrigadas(Descripcion,
        Traduccion)
		VALUES(
            @Descripcion,
          case when ISJSON(@Traduccion) > 0 then @Traduccion else null end
        )
		
		SET @IDBrigada = @@IDENTITY

		
		select @NewJSON =(SELECT IDBrigada
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [RH].[tblCatBrigadas] 
                            WHERE IDBrigada = @IDBrigada FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) 
    

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatBrigadas]','[RH].[spUICatBrigadas]','INSERT',@NewJSON,''
	END
	ELSE
	BEGIN

		
		select @OldJSON = (SELECT IDBrigada
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [RH].[tblCatBrigadas] 
                            WHERE IDBrigada = @IDBrigada FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) 

		UPDATE RH.tblCatBrigadas
			set Descripcion = @Descripcion,
            [Traduccion] = case when ISJSON(@Traduccion) > 0 then @Traduccion else null end
		Where IDBrigada = @IDBrigada

		
		select @NewJSON = (SELECT IDBrigada
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [RH].[tblCatBrigadas] 
                            WHERE IDBrigada = @IDBrigada FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) 

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatBrigadas]','[RH].[spUICatBrigadas]','UPDATE',@NewJSON,@OldJSON
	END
	
	SELECT IDBrigada,
		   Descripcion,
           Traduccion,
		   ROW_NUMBER()over(ORDER BY IDBrigada)as ROWNUMBER
	FROM RH.tblCatBrigadas
	Where IDBrigada = @IDBrigada
END
GO
