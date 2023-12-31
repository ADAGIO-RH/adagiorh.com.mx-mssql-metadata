USE [p_adagioRHBelmondCSN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Obtener Encuestas
** Autor			: Denzel Ovando
** Email			: denzel.ovando@adagio.com.mx
** FechaCreacion	: 2020-06-17
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/



CREATE proc [Norma035].[spObtenerResultado]
(@IDEncuestaEmpleado int,@TipoEncuesta int)
as
BEGIN
	DECLARE @temp_preguntas_reales int;
	DECLARE @temp_preguntas_sistema int;
	
	IF @TipoEncuesta=1 
		BEGIN
			SELECT @temp_preguntas_sistema= COUNT(*) from Norma035.tblCatPreguntas
			inner join   Norma035.tblRespuestasEmpleados on  Norma035.tblRespuestasEmpleados.IDPregunta=Norma035.tblCatPreguntas.IDPregunta
			where IDSeccion=1 AND Respuesta=2 AND Norma035.tblRespuestasEmpleados.IDEncuestaEmpleado=@IDEncuestaEmpleado;


			SELECT @temp_preguntas_reales= COUNT(*) from Norma035.tblCatPreguntas
			inner join   Norma035.tblRespuestasEmpleados on  Norma035.tblRespuestasEmpleados.IDPregunta=Norma035.tblCatPreguntas.IDPregunta
			where IDSeccion=1 AND Norma035.tblRespuestasEmpleados.IDEncuestaEmpleado=@IDEncuestaEmpleado;

			if @temp_preguntas_reales= @temp_preguntas_sistema 
				BEGIN
					UPDATE Norma035.tblEncuestaEmpleado SET 
					Norma035.tblEncuestaEmpleado.Resultado = ' el trabajador no requiere una valoración clínica' , NivelRiesgo='No reportó Acontecimientos traumáticos severos'
					WHERE Norma035.tblEncuestaEmpleado .IDEncuestaEmpleado=@IDEncuestaEmpleado;
				END
			ELSE
				BEGIN
					-- CASO SECCION 2 . SOLO DEBE RESPONDER SI A CUALQUIERA		
					SELECT @temp_preguntas_sistema= COUNT(*) from Norma035.tblCatPreguntas
					inner join   Norma035.tblRespuestasEmpleados on  Norma035.tblRespuestasEmpleados.IDPregunta=Norma035.tblCatPreguntas.IDPregunta
					where IDSeccion=2 AND Respuesta=1 AND Norma035.tblRespuestasEmpleados.IDEncuestaEmpleado=@IDEncuestaEmpleado;

					if @temp_preguntas_sistema>0
						BEGIN
							UPDATE Norma035.tblEncuestaEmpleado SET 
							Norma035.tblEncuestaEmpleado.Resultado = 'El trabajador  requiere una valoración clínica' , NivelRiesgo='Reportó Acontecimientos traumáticos severos'
							WHERE Norma035.tblEncuestaEmpleado .IDEncuestaEmpleado=@IDEncuestaEmpleado;
						END
					ELSE 

						BEGIN
							-- CASO SECCION 3 . SOLO DEBE RESPONDER A 3 O MAS
								SELECT @temp_preguntas_sistema= COUNT(*) from Norma035.tblCatPreguntas
								inner join   Norma035.tblRespuestasEmpleados on  Norma035.tblRespuestasEmpleados.IDPregunta=Norma035.tblCatPreguntas.IDPregunta
								where IDSeccion=3 AND Respuesta=1 AND Norma035.tblRespuestasEmpleados.IDEncuestaEmpleado=@IDEncuestaEmpleado;

								if @temp_preguntas_sistema>=3
									BEGIN
										UPDATE Norma035.tblEncuestaEmpleado SET 
										Norma035.tblEncuestaEmpleado.Resultado = 'El trabajador  requiere una valoración clínica' , NivelRiesgo='Reportó Acontecimientos traumáticos severos'
										WHERE Norma035.tblEncuestaEmpleado .IDEncuestaEmpleado=@IDEncuestaEmpleado;
									END
								ELSE 
									BEGIN
										-- CASO SECCION 4 . SOLO DEBE RESPONDER A 2 O MAS
										SELECT @temp_preguntas_sistema= COUNT(*) from Norma035.tblCatPreguntas
										inner join   Norma035.tblRespuestasEmpleados on  Norma035.tblRespuestasEmpleados.IDPregunta=Norma035.tblCatPreguntas.IDPregunta
										where IDSeccion=4 AND Respuesta=1 AND Norma035.tblRespuestasEmpleados.IDEncuestaEmpleado=@IDEncuestaEmpleado;

										if @temp_preguntas_sistema>=2
											BEGIN
												UPDATE Norma035.tblEncuestaEmpleado SET 
												Norma035.tblEncuestaEmpleado.Resultado = 'El trabajador  requiere una valoración clínica' , NivelRiesgo='Reportó Acontecimientos traumáticos severos'
												WHERE Norma035.tblEncuestaEmpleado .IDEncuestaEmpleado=@IDEncuestaEmpleado;
											END
										ELSE 
											BEGIN
												UPDATE Norma035.tblEncuestaEmpleado SET 
												Norma035.tblEncuestaEmpleado.Resultado = ' el trabajador no requiere una valoración clínica' , NivelRiesgo='No reportó Acontecimientos traumáticos severos'
												WHERE Norma035.tblEncuestaEmpleado .IDEncuestaEmpleado=@IDEncuestaEmpleado;
											END
									END
						END

				END
			END
		ELSE IF @TipoEncuesta=2
			BEGIN
				SELECT @temp_preguntas_sistema= sum(Respuesta) from Norma035.tblCatPreguntas
				inner join   Norma035.tblRespuestasEmpleados on  Norma035.tblRespuestasEmpleados.IDPregunta=Norma035.tblCatPreguntas.IDPregunta
				where   Norma035.tblRespuestasEmpleados.IDEncuestaEmpleado=@IDEncuestaEmpleado;

				IF   @temp_preguntas_sistema< 20
						BEGIN
							UPDATE Norma035.tblEncuestaEmpleado SET 
							Norma035.tblEncuestaEmpleado.Resultado = 'El riesgo resulta despreciable por lo que no se requiere medidas adicionales' , NivelRiesgo='Nulo o despreciable'
							WHERE Norma035.tblEncuestaEmpleado .IDEncuestaEmpleado=@IDEncuestaEmpleado;
						END
				ELSE IF @temp_preguntas_sistema< 45
						BEGIN
							UPDATE Norma035.tblEncuestaEmpleado SET 
							Norma035.tblEncuestaEmpleado.Resultado = 'Es necesario una mayor difusión de la política de prevención de riesgos psicosociales y programas para: la prevención de los factores de riesgo psicosocial, la promoción de un entorno organizacional favorable y la prevención de la violencia laboral.' , NivelRiesgo='BAJO'
							WHERE Norma035.tblEncuestaEmpleado .IDEncuestaEmpleado=@IDEncuestaEmpleado;
						END
				ELSE IF @temp_preguntas_sistema< 70
					BEGIN
						UPDATE Norma035.tblEncuestaEmpleado SET 
						Norma035.tblEncuestaEmpleado.Resultado = 'Se requiere revisar la política de prevención de riesgos psicosociales y programas para la prevención de los factores de riesgo psicosocial, la promoción de un entorno organizacional favorable y la prevención de la violencia laboral, así como reforzar su aplicación y difusión, mediante un Programa de intervención.' , NivelRiesgo='MEDIO'
						WHERE Norma035.tblEncuestaEmpleado .IDEncuestaEmpleado=@IDEncuestaEmpleado;
					END
				ELSE IF @temp_preguntas_sistema< 90
						BEGIN
							UPDATE Norma035.tblEncuestaEmpleado SET 
							Norma035.tblEncuestaEmpleado.Resultado = 'Se requiere realizar un análisis de cada categoría y dominio, de manera que se puedan determinar las acciones de intervención apropiadas a través de un Programa de intervención, que podrá incluir una evaluación específica1 y deberá incluir una campaña de sensibilización, revisar la política de prevención de riesgos psicosociales y programas para la prevención de los factores de riesgo psicosocial, la promoción de un entorno organizacional favorable y la prevención de la violencia laboral, así como reforzar su aplicación y difusión.' , NivelRiesgo='ALTO'
							WHERE Norma035.tblEncuestaEmpleado .IDEncuestaEmpleado=@IDEncuestaEmpleado;
						END
				ELSE 
						BEGIN
							UPDATE Norma035.tblEncuestaEmpleado SET 
							Norma035.tblEncuestaEmpleado.Resultado = 'Se requiere realizar el análisis de cada categoría y dominio para establecer las acciones de intervención apropiadas, mediante un Programa de intervención que deberá incluir evaluaciones específicas1, y contemplar campañas de sensibilización, revisar la política de prevención de riesgos psicosociales y programas para la prevención de los factores de riesgo psicosocial, la promoción de un entorno organizacional favorable y la prevención de la violencia laboral, así como reforzar su aplicación y difusión.' , NivelRiesgo='Muy alto'
							WHERE Norma035.tblEncuestaEmpleado .IDEncuestaEmpleado=@IDEncuestaEmpleado;
						END				 
	 		END
		ELSE IF @TipoEncuesta=3
			BEGIN
				SELECT @temp_preguntas_sistema= sum(Respuesta) from Norma035.tblCatPreguntas
				inner join   Norma035.tblRespuestasEmpleados on  Norma035.tblRespuestasEmpleados.IDPregunta=Norma035.tblCatPreguntas.IDPregunta
				where   Norma035.tblRespuestasEmpleados.IDEncuestaEmpleado=@IDEncuestaEmpleado;

				IF   @temp_preguntas_sistema< 50
						BEGIN
							UPDATE Norma035.tblEncuestaEmpleado SET 
							Norma035.tblEncuestaEmpleado.Resultado = 'El riesgo resulta despreciable por lo que no se requiere medidas adicionales' , NivelRiesgo='Nulo o despreciable'
							WHERE Norma035.tblEncuestaEmpleado .IDEncuestaEmpleado=@IDEncuestaEmpleado;
						END
				ELSE IF @temp_preguntas_sistema< 75
						BEGIN
							UPDATE Norma035.tblEncuestaEmpleado SET 
							Norma035.tblEncuestaEmpleado.Resultado = 'Es necesario una mayor difusión de la política de prevención de riesgos psicosociales y programas para: la prevención de los factores de riesgo psicosocial, la promoción de un entorno organizacional favorable y la prevención de la violencia laboral.' , NivelRiesgo='BAJO'
							WHERE Norma035.tblEncuestaEmpleado .IDEncuestaEmpleado=@IDEncuestaEmpleado;
						END
				ELSE IF @temp_preguntas_sistema< 99
					BEGIN
						UPDATE Norma035.tblEncuestaEmpleado SET 
						Norma035.tblEncuestaEmpleado.Resultado = 'Se requiere revisar la política de prevención de riesgos psicosociales y programas para la prevención de los factores de riesgo psicosocial, la promoción de un entorno organizacional favorable y la prevención de la violencia laboral, así como reforzar su aplicación y difusión, mediante un Programa de intervención.' , NivelRiesgo='MEDIO'
						WHERE Norma035.tblEncuestaEmpleado .IDEncuestaEmpleado=@IDEncuestaEmpleado;
					END
				ELSE IF @temp_preguntas_sistema< 140
						BEGIN
							UPDATE Norma035.tblEncuestaEmpleado SET 
							Norma035.tblEncuestaEmpleado.Resultado = 'Se requiere realizar un análisis de cada categoría y dominio, de manera que se puedan determinar las acciones de intervención apropiadas a través de un Programa de intervención, que podrá incluir una evaluación específica1 y deberá incluir una campaña de sensibilización, revisar la política de prevención de riesgos psicosociales y programas para la prevención de los factores de riesgo psicosocial, la promoción de un entorno organizacional favorable y la prevención de la violencia laboral, así como reforzar su aplicación y difusión.' , NivelRiesgo='ALTO'
							WHERE Norma035.tblEncuestaEmpleado .IDEncuestaEmpleado=@IDEncuestaEmpleado;
						END
				ELSE 
						BEGIN
							UPDATE Norma035.tblEncuestaEmpleado SET 
							Norma035.tblEncuestaEmpleado.Resultado = 'Se requiere realizar el análisis de cada categoría y dominio para establecer las acciones de intervención apropiadas, mediante un Programa de intervención que deberá incluir evaluaciones específicas1, y contemplar campañas de sensibilización, revisar la política de prevención de riesgos psicosociales y programas para la prevención de los factores de riesgo psicosocial, la promoción de un entorno organizacional favorable y la prevención de la violencia laboral, así como reforzar su aplicación y difusión.' , NivelRiesgo='Muy alto'
							WHERE Norma035.tblEncuestaEmpleado .IDEncuestaEmpleado=@IDEncuestaEmpleado;
						END				 
	 		END
end
GO
