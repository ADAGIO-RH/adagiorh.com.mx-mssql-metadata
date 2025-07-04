USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tareas].[tblTareas](
	[IDTarea] [int] IDENTITY(1,1) NOT NULL,
	[Titulo] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaRegistro] [datetime] NULL,
	[IDUsuarioCreacion] [int] NULL,
	[IDTipoTablero] [int] NULL,
	[IDReferencia] [int] NULL,
	[IDEstatusTarea] [int] NULL,
	[FechaInicio] [date] NULL,
	[FechaFin] [date] NULL,
	[IDPrioridad] [int] NULL,
	[IDUsuariosAsignados] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Orden] [int] NULL,
	[TotalComentarios] [int] NULL,
	[TotalCheckListActivos] [int] NULL,
	[TotalCheckListNoActivos] [int] NULL,
	[IDUnidadDeTiempo] [int] NULL,
	[ValorUnidadTIempo] [int] NULL,
	[CheckListJson] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Archivado] [bit] NULL,
	[TotalAdjuntos] [int] NULL,
 CONSTRAINT [Pk_TareasTblTareas_IDTarea] PRIMARY KEY CLUSTERED 
(
	[IDTarea] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_IDTarea] ON [Tareas].[tblTareas]
(
	[IDTarea] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Tareas].[tblTareas] ADD  DEFAULT (getdate()) FOR [FechaRegistro]
GO
ALTER TABLE [Tareas].[tblTareas] ADD  DEFAULT ((0)) FOR [Archivado]
GO
ALTER TABLE [Tareas].[tblTareas]  WITH CHECK ADD  CONSTRAINT [FK_TareasTblTareas_TareasTblCatEstatusTareas_IDEstatusTarea] FOREIGN KEY([IDEstatusTarea])
REFERENCES [Tareas].[tblCatEstatusTareas] ([IDEstatusTarea])
GO
ALTER TABLE [Tareas].[tblTareas] CHECK CONSTRAINT [FK_TareasTblTareas_TareasTblCatEstatusTareas_IDEstatusTarea]
GO
ALTER TABLE [Tareas].[tblTareas]  WITH CHECK ADD  CONSTRAINT [FK_TareasTblTareas_TareasTblCatPrioridad_IDPrioridad] FOREIGN KEY([IDPrioridad])
REFERENCES [Tareas].[tblCatPrioridad] ([IDPrioridad])
GO
ALTER TABLE [Tareas].[tblTareas] CHECK CONSTRAINT [FK_TareasTblTareas_TareasTblCatPrioridad_IDPrioridad]
GO
ALTER TABLE [Tareas].[tblTareas]  WITH CHECK ADD  CONSTRAINT [FK_TareasTblTareas_TareasTblTiposTareas_IDTipoTablero] FOREIGN KEY([IDTipoTablero])
REFERENCES [Tareas].[tblCatTipoTablero] ([IDTipoTablero])
GO
ALTER TABLE [Tareas].[tblTareas] CHECK CONSTRAINT [FK_TareasTblTareas_TareasTblTiposTareas_IDTipoTablero]
GO
