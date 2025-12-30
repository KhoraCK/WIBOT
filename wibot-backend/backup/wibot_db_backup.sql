--
-- PostgreSQL database dump
--

\restrict zzcwbK87BrutcG5idwLSeW6MIn24OsXUtctssEp8Azkjg7I2sogeK32vohvY7cy

-- Dumped from database version 14.20
-- Dumped by pg_dump version 14.20

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: increment_workflow_version(); Type: FUNCTION; Schema: public; Owner: widip
--

CREATE FUNCTION public.increment_workflow_version() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
			BEGIN
				IF NEW."versionCounter" IS NOT DISTINCT FROM OLD."versionCounter" THEN
					NEW."versionCounter" = OLD."versionCounter" + 1;
				END IF;
				RETURN NEW;
			END;
			$$;


ALTER FUNCTION public.increment_workflow_version() OWNER TO widip;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: widip
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO widip;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: annotation_tag_entity; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.annotation_tag_entity (
    id character varying(16) NOT NULL,
    name character varying(24) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.annotation_tag_entity OWNER TO widip;

--
-- Name: auth_identity; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.auth_identity (
    "userId" uuid,
    "providerId" character varying(64) NOT NULL,
    "providerType" character varying(32) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.auth_identity OWNER TO widip;

--
-- Name: auth_provider_sync_history; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.auth_provider_sync_history (
    id integer NOT NULL,
    "providerType" character varying(32) NOT NULL,
    "runMode" text NOT NULL,
    status text NOT NULL,
    "startedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "endedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    scanned integer NOT NULL,
    created integer NOT NULL,
    updated integer NOT NULL,
    disabled integer NOT NULL,
    error text
);


ALTER TABLE public.auth_provider_sync_history OWNER TO widip;

--
-- Name: auth_provider_sync_history_id_seq; Type: SEQUENCE; Schema: public; Owner: widip
--

CREATE SEQUENCE public.auth_provider_sync_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_provider_sync_history_id_seq OWNER TO widip;

--
-- Name: auth_provider_sync_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: widip
--

ALTER SEQUENCE public.auth_provider_sync_history_id_seq OWNED BY public.auth_provider_sync_history.id;


--
-- Name: binary_data; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.binary_data (
    "fileId" uuid NOT NULL,
    "sourceType" character varying(50) NOT NULL,
    "sourceId" character varying(255) NOT NULL,
    data bytea NOT NULL,
    "mimeType" character varying(255),
    "fileName" character varying(255),
    "fileSize" integer NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    CONSTRAINT "CHK_binary_data_sourceType" CHECK ((("sourceType")::text = ANY ((ARRAY['execution'::character varying, 'chat_message_attachment'::character varying])::text[])))
);


ALTER TABLE public.binary_data OWNER TO widip;

--
-- Name: COLUMN binary_data."sourceType"; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.binary_data."sourceType" IS 'Source the file belongs to, e.g. ''execution''';


--
-- Name: COLUMN binary_data."sourceId"; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.binary_data."sourceId" IS 'ID of the source, e.g. execution ID';


--
-- Name: COLUMN binary_data.data; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.binary_data.data IS 'Raw, not base64 encoded';


--
-- Name: COLUMN binary_data."fileSize"; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.binary_data."fileSize" IS 'In bytes';


--
-- Name: chat_hub_agents; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.chat_hub_agents (
    id uuid NOT NULL,
    name character varying(256) NOT NULL,
    description character varying(512),
    "systemPrompt" text NOT NULL,
    "ownerId" uuid NOT NULL,
    "credentialId" character varying(36),
    provider character varying(16) NOT NULL,
    model character varying(64) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    tools json DEFAULT '[]'::json NOT NULL
);


ALTER TABLE public.chat_hub_agents OWNER TO widip;

--
-- Name: COLUMN chat_hub_agents.provider; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.chat_hub_agents.provider IS 'ChatHubProvider enum: "openai", "anthropic", "google", "n8n"';


--
-- Name: COLUMN chat_hub_agents.model; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.chat_hub_agents.model IS 'Model name used at the respective Model node, ie. "gpt-4"';


--
-- Name: COLUMN chat_hub_agents.tools; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.chat_hub_agents.tools IS 'Tools available to the agent as JSON node definitions';


--
-- Name: chat_hub_messages; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.chat_hub_messages (
    id uuid NOT NULL,
    "sessionId" uuid NOT NULL,
    "previousMessageId" uuid,
    "revisionOfMessageId" uuid,
    "retryOfMessageId" uuid,
    type character varying(16) NOT NULL,
    name character varying(128) NOT NULL,
    content text NOT NULL,
    provider character varying(16),
    model character varying(64),
    "workflowId" character varying(36),
    "executionId" integer,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "agentId" character varying(36),
    status character varying(16) DEFAULT 'success'::character varying NOT NULL,
    attachments json
);


ALTER TABLE public.chat_hub_messages OWNER TO widip;

--
-- Name: COLUMN chat_hub_messages.type; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.chat_hub_messages.type IS 'ChatHubMessageType enum: "human", "ai", "system", "tool", "generic"';


--
-- Name: COLUMN chat_hub_messages.provider; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.chat_hub_messages.provider IS 'ChatHubProvider enum: "openai", "anthropic", "google", "n8n"';


--
-- Name: COLUMN chat_hub_messages.model; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.chat_hub_messages.model IS 'Model name used at the respective Model node, ie. "gpt-4"';


--
-- Name: COLUMN chat_hub_messages."agentId"; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.chat_hub_messages."agentId" IS 'ID of the custom agent (if provider is "custom-agent")';


--
-- Name: COLUMN chat_hub_messages.status; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.chat_hub_messages.status IS 'ChatHubMessageStatus enum, eg. "success", "error", "running", "cancelled"';


--
-- Name: COLUMN chat_hub_messages.attachments; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.chat_hub_messages.attachments IS 'File attachments for the message (if any), stored as JSON. Files are stored as base64-encoded data URLs.';


--
-- Name: chat_hub_sessions; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.chat_hub_sessions (
    id uuid NOT NULL,
    title character varying(256) NOT NULL,
    "ownerId" uuid NOT NULL,
    "lastMessageAt" timestamp(3) with time zone,
    "credentialId" character varying(36),
    provider character varying(16),
    model character varying(64),
    "workflowId" character varying(36),
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "agentId" character varying(36),
    "agentName" character varying(128),
    tools json DEFAULT '[]'::json NOT NULL
);


ALTER TABLE public.chat_hub_sessions OWNER TO widip;

--
-- Name: COLUMN chat_hub_sessions.provider; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.chat_hub_sessions.provider IS 'ChatHubProvider enum: "openai", "anthropic", "google", "n8n"';


--
-- Name: COLUMN chat_hub_sessions.model; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.chat_hub_sessions.model IS 'Model name used at the respective Model node, ie. "gpt-4"';


--
-- Name: COLUMN chat_hub_sessions."agentId"; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.chat_hub_sessions."agentId" IS 'ID of the custom agent (if provider is "custom-agent")';


--
-- Name: COLUMN chat_hub_sessions."agentName"; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.chat_hub_sessions."agentName" IS 'Cached name of the custom agent (if provider is "custom-agent")';


--
-- Name: COLUMN chat_hub_sessions.tools; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.chat_hub_sessions.tools IS 'Tools available to the agent as JSON node definitions';


--
-- Name: conversations; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.conversations (
    conversation_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id integer,
    title character varying(255),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.conversations OWNER TO widip;

--
-- Name: TABLE conversations; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON TABLE public.conversations IS 'Conversations chat WIBOT';


--
-- Name: credentials_entity; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.credentials_entity (
    name character varying(128) NOT NULL,
    data text NOT NULL,
    type character varying(128) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    id character varying(36) NOT NULL,
    "isManaged" boolean DEFAULT false NOT NULL,
    "isGlobal" boolean DEFAULT false NOT NULL
);


ALTER TABLE public.credentials_entity OWNER TO widip;

--
-- Name: data_table; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.data_table (
    id character varying(36) NOT NULL,
    name character varying(128) NOT NULL,
    "projectId" character varying(36) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.data_table OWNER TO widip;

--
-- Name: data_table_column; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.data_table_column (
    id character varying(36) NOT NULL,
    name character varying(128) NOT NULL,
    type character varying(32) NOT NULL,
    index integer NOT NULL,
    "dataTableId" character varying(36) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.data_table_column OWNER TO widip;

--
-- Name: COLUMN data_table_column.type; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.data_table_column.type IS 'Expected: string, number, boolean, or date (not enforced as a constraint)';


--
-- Name: COLUMN data_table_column.index; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.data_table_column.index IS 'Column order, starting from 0 (0 = first column)';


--
-- Name: event_destinations; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.event_destinations (
    id uuid NOT NULL,
    destination jsonb NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.event_destinations OWNER TO widip;

--
-- Name: execution_annotation_tags; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.execution_annotation_tags (
    "annotationId" integer NOT NULL,
    "tagId" character varying(24) NOT NULL
);


ALTER TABLE public.execution_annotation_tags OWNER TO widip;

--
-- Name: execution_annotations; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.execution_annotations (
    id integer NOT NULL,
    "executionId" integer NOT NULL,
    vote character varying(6),
    note text,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.execution_annotations OWNER TO widip;

--
-- Name: execution_annotations_id_seq; Type: SEQUENCE; Schema: public; Owner: widip
--

CREATE SEQUENCE public.execution_annotations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.execution_annotations_id_seq OWNER TO widip;

--
-- Name: execution_annotations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: widip
--

ALTER SEQUENCE public.execution_annotations_id_seq OWNED BY public.execution_annotations.id;


--
-- Name: execution_data; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.execution_data (
    "executionId" integer NOT NULL,
    "workflowData" json NOT NULL,
    data text NOT NULL
);


ALTER TABLE public.execution_data OWNER TO widip;

--
-- Name: execution_entity; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.execution_entity (
    id integer NOT NULL,
    finished boolean NOT NULL,
    mode character varying NOT NULL,
    "retryOf" character varying,
    "retrySuccessId" character varying,
    "startedAt" timestamp(3) with time zone,
    "stoppedAt" timestamp(3) with time zone,
    "waitTill" timestamp(3) with time zone,
    status character varying NOT NULL,
    "workflowId" character varying(36) NOT NULL,
    "deletedAt" timestamp(3) with time zone,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.execution_entity OWNER TO widip;

--
-- Name: execution_entity_id_seq; Type: SEQUENCE; Schema: public; Owner: widip
--

CREATE SEQUENCE public.execution_entity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.execution_entity_id_seq OWNER TO widip;

--
-- Name: execution_entity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: widip
--

ALTER SEQUENCE public.execution_entity_id_seq OWNED BY public.execution_entity.id;


--
-- Name: execution_metadata; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.execution_metadata (
    id integer NOT NULL,
    "executionId" integer NOT NULL,
    key character varying(255) NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.execution_metadata OWNER TO widip;

--
-- Name: execution_metadata_temp_id_seq; Type: SEQUENCE; Schema: public; Owner: widip
--

CREATE SEQUENCE public.execution_metadata_temp_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.execution_metadata_temp_id_seq OWNER TO widip;

--
-- Name: execution_metadata_temp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: widip
--

ALTER SEQUENCE public.execution_metadata_temp_id_seq OWNED BY public.execution_metadata.id;


--
-- Name: folder; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.folder (
    id character varying(36) NOT NULL,
    name character varying(128) NOT NULL,
    "parentFolderId" character varying(36),
    "projectId" character varying(36) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.folder OWNER TO widip;

--
-- Name: folder_tag; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.folder_tag (
    "folderId" character varying(36) NOT NULL,
    "tagId" character varying(36) NOT NULL
);


ALTER TABLE public.folder_tag OWNER TO widip;

--
-- Name: insights_by_period; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.insights_by_period (
    id integer NOT NULL,
    "metaId" integer NOT NULL,
    type integer NOT NULL,
    value bigint NOT NULL,
    "periodUnit" integer NOT NULL,
    "periodStart" timestamp(0) with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.insights_by_period OWNER TO widip;

--
-- Name: COLUMN insights_by_period.type; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.insights_by_period.type IS '0: time_saved_minutes, 1: runtime_milliseconds, 2: success, 3: failure';


--
-- Name: COLUMN insights_by_period."periodUnit"; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.insights_by_period."periodUnit" IS '0: hour, 1: day, 2: week';


--
-- Name: insights_by_period_id_seq; Type: SEQUENCE; Schema: public; Owner: widip
--

ALTER TABLE public.insights_by_period ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.insights_by_period_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: insights_metadata; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.insights_metadata (
    "metaId" integer NOT NULL,
    "workflowId" character varying(16),
    "projectId" character varying(36),
    "workflowName" character varying(128) NOT NULL,
    "projectName" character varying(255) NOT NULL
);


ALTER TABLE public.insights_metadata OWNER TO widip;

--
-- Name: insights_metadata_metaId_seq; Type: SEQUENCE; Schema: public; Owner: widip
--

ALTER TABLE public.insights_metadata ALTER COLUMN "metaId" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."insights_metadata_metaId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: insights_raw; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.insights_raw (
    id integer NOT NULL,
    "metaId" integer NOT NULL,
    type integer NOT NULL,
    value bigint NOT NULL,
    "timestamp" timestamp(0) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.insights_raw OWNER TO widip;

--
-- Name: COLUMN insights_raw.type; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.insights_raw.type IS '0: time_saved_minutes, 1: runtime_milliseconds, 2: success, 3: failure';


--
-- Name: insights_raw_id_seq; Type: SEQUENCE; Schema: public; Owner: widip
--

ALTER TABLE public.insights_raw ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.insights_raw_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: installed_nodes; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.installed_nodes (
    name character varying(200) NOT NULL,
    type character varying(200) NOT NULL,
    "latestVersion" integer DEFAULT 1 NOT NULL,
    package character varying(241) NOT NULL
);


ALTER TABLE public.installed_nodes OWNER TO widip;

--
-- Name: installed_packages; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.installed_packages (
    "packageName" character varying(214) NOT NULL,
    "installedVersion" character varying(50) NOT NULL,
    "authorName" character varying(70),
    "authorEmail" character varying(70),
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.installed_packages OWNER TO widip;

--
-- Name: invalid_auth_token; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.invalid_auth_token (
    token character varying(512) NOT NULL,
    "expiresAt" timestamp(3) with time zone NOT NULL
);


ALTER TABLE public.invalid_auth_token OWNER TO widip;

--
-- Name: messages; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.messages (
    message_id integer NOT NULL,
    conversation_id uuid,
    user_id integer,
    role character varying(20) NOT NULL,
    content text NOT NULL,
    tokens integer DEFAULT 0,
    attachments jsonb,
    created_at timestamp without time zone DEFAULT now(),
    CONSTRAINT messages_role_check CHECK (((role)::text = ANY ((ARRAY['user'::character varying, 'assistant'::character varying])::text[])))
);


ALTER TABLE public.messages OWNER TO widip;

--
-- Name: TABLE messages; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON TABLE public.messages IS 'Messages des conversations';


--
-- Name: COLUMN messages.role; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.messages.role IS 'user ou assistant uniquement';


--
-- Name: COLUMN messages.attachments; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.messages.attachments IS 'Metadonnees fichiers joints (optionnel)';


--
-- Name: messages_message_id_seq; Type: SEQUENCE; Schema: public; Owner: widip
--

CREATE SEQUENCE public.messages_message_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.messages_message_id_seq OWNER TO widip;

--
-- Name: messages_message_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: widip
--

ALTER SEQUENCE public.messages_message_id_seq OWNED BY public.messages.message_id;


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    "timestamp" bigint NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.migrations OWNER TO widip;

--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: widip
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.migrations_id_seq OWNER TO widip;

--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: widip
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: n8n_chat_histories; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.n8n_chat_histories (
    id integer NOT NULL,
    session_id character varying(255) NOT NULL,
    message jsonb NOT NULL
);


ALTER TABLE public.n8n_chat_histories OWNER TO widip;

--
-- Name: n8n_chat_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: widip
--

CREATE SEQUENCE public.n8n_chat_histories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.n8n_chat_histories_id_seq OWNER TO widip;

--
-- Name: n8n_chat_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: widip
--

ALTER SEQUENCE public.n8n_chat_histories_id_seq OWNED BY public.n8n_chat_histories.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.oauth_access_tokens (
    token character varying NOT NULL,
    "clientId" character varying NOT NULL,
    "userId" uuid NOT NULL
);


ALTER TABLE public.oauth_access_tokens OWNER TO widip;

--
-- Name: oauth_authorization_codes; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.oauth_authorization_codes (
    code character varying(255) NOT NULL,
    "clientId" character varying NOT NULL,
    "userId" uuid NOT NULL,
    "redirectUri" character varying NOT NULL,
    "codeChallenge" character varying NOT NULL,
    "codeChallengeMethod" character varying(255) NOT NULL,
    "expiresAt" bigint NOT NULL,
    state character varying,
    used boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.oauth_authorization_codes OWNER TO widip;

--
-- Name: COLUMN oauth_authorization_codes."expiresAt"; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.oauth_authorization_codes."expiresAt" IS 'Unix timestamp in milliseconds';


--
-- Name: oauth_clients; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.oauth_clients (
    id character varying NOT NULL,
    name character varying(255) NOT NULL,
    "redirectUris" json NOT NULL,
    "grantTypes" json NOT NULL,
    "clientSecret" character varying(255),
    "clientSecretExpiresAt" bigint,
    "tokenEndpointAuthMethod" character varying(255) DEFAULT 'none'::character varying NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.oauth_clients OWNER TO widip;

--
-- Name: COLUMN oauth_clients."tokenEndpointAuthMethod"; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.oauth_clients."tokenEndpointAuthMethod" IS 'Possible values: none, client_secret_basic or client_secret_post';


--
-- Name: oauth_refresh_tokens; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.oauth_refresh_tokens (
    token character varying(255) NOT NULL,
    "clientId" character varying NOT NULL,
    "userId" uuid NOT NULL,
    "expiresAt" bigint NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.oauth_refresh_tokens OWNER TO widip;

--
-- Name: COLUMN oauth_refresh_tokens."expiresAt"; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.oauth_refresh_tokens."expiresAt" IS 'Unix timestamp in milliseconds';


--
-- Name: oauth_user_consents; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.oauth_user_consents (
    id integer NOT NULL,
    "userId" uuid NOT NULL,
    "clientId" character varying NOT NULL,
    "grantedAt" bigint NOT NULL
);


ALTER TABLE public.oauth_user_consents OWNER TO widip;

--
-- Name: COLUMN oauth_user_consents."grantedAt"; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.oauth_user_consents."grantedAt" IS 'Unix timestamp in milliseconds';


--
-- Name: oauth_user_consents_id_seq; Type: SEQUENCE; Schema: public; Owner: widip
--

ALTER TABLE public.oauth_user_consents ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.oauth_user_consents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: processed_data; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.processed_data (
    "workflowId" character varying(36) NOT NULL,
    context character varying(255) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.processed_data OWNER TO widip;

--
-- Name: project; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.project (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    type character varying(36) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    icon json,
    description character varying(512)
);


ALTER TABLE public.project OWNER TO widip;

--
-- Name: project_relation; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.project_relation (
    "projectId" character varying(36) NOT NULL,
    "userId" uuid NOT NULL,
    role character varying NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.project_relation OWNER TO widip;

--
-- Name: role; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.role (
    slug character varying(128) NOT NULL,
    "displayName" text,
    description text,
    "roleType" text,
    "systemRole" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.role OWNER TO widip;

--
-- Name: COLUMN role.slug; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.role.slug IS 'Unique identifier of the role for example: "global:owner"';


--
-- Name: COLUMN role."displayName"; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.role."displayName" IS 'Name used to display in the UI';


--
-- Name: COLUMN role.description; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.role.description IS 'Text describing the scope in more detail of users';


--
-- Name: COLUMN role."roleType"; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.role."roleType" IS 'Type of the role, e.g., global, project, or workflow';


--
-- Name: COLUMN role."systemRole"; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.role."systemRole" IS 'Indicates if the role is managed by the system and cannot be edited';


--
-- Name: role_scope; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.role_scope (
    "roleSlug" character varying(128) NOT NULL,
    "scopeSlug" character varying(128) NOT NULL
);


ALTER TABLE public.role_scope OWNER TO widip;

--
-- Name: scope; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.scope (
    slug character varying(128) NOT NULL,
    "displayName" text,
    description text
);


ALTER TABLE public.scope OWNER TO widip;

--
-- Name: COLUMN scope.slug; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.scope.slug IS 'Unique identifier of the scope for example: "project:create"';


--
-- Name: COLUMN scope."displayName"; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.scope."displayName" IS 'Name used to display in the UI';


--
-- Name: COLUMN scope.description; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.scope.description IS 'Text describing the scope in more detail of users';


--
-- Name: settings; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.settings (
    key character varying(255) NOT NULL,
    value text NOT NULL,
    "loadOnStartup" boolean DEFAULT false NOT NULL
);


ALTER TABLE public.settings OWNER TO widip;

--
-- Name: shared_credentials; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.shared_credentials (
    "credentialsId" character varying(36) NOT NULL,
    "projectId" character varying(36) NOT NULL,
    role text NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.shared_credentials OWNER TO widip;

--
-- Name: shared_workflow; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.shared_workflow (
    "workflowId" character varying(36) NOT NULL,
    "projectId" character varying(36) NOT NULL,
    role text NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.shared_workflow OWNER TO widip;

--
-- Name: tag_entity; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.tag_entity (
    name character varying(24) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    id character varying(36) NOT NULL
);


ALTER TABLE public.tag_entity OWNER TO widip;

--
-- Name: test_case_execution; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.test_case_execution (
    id character varying(36) NOT NULL,
    "testRunId" character varying(36) NOT NULL,
    "executionId" integer,
    status character varying NOT NULL,
    "runAt" timestamp(3) with time zone,
    "completedAt" timestamp(3) with time zone,
    "errorCode" character varying,
    "errorDetails" json,
    metrics json,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    inputs json,
    outputs json
);


ALTER TABLE public.test_case_execution OWNER TO widip;

--
-- Name: test_run; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.test_run (
    id character varying(36) NOT NULL,
    "workflowId" character varying(36) NOT NULL,
    status character varying NOT NULL,
    "errorCode" character varying,
    "errorDetails" json,
    "runAt" timestamp(3) with time zone,
    "completedAt" timestamp(3) with time zone,
    metrics json,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.test_run OWNER TO widip;

--
-- Name: user; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public."user" (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(255),
    "firstName" character varying(32),
    "lastName" character varying(32),
    password character varying(255),
    "personalizationAnswers" json,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    settings json,
    disabled boolean DEFAULT false NOT NULL,
    "mfaEnabled" boolean DEFAULT false NOT NULL,
    "mfaSecret" text,
    "mfaRecoveryCodes" text,
    "lastActiveAt" date,
    "roleSlug" character varying(128) DEFAULT 'global:member'::character varying NOT NULL
);


ALTER TABLE public."user" OWNER TO widip;

--
-- Name: user_api_keys; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.user_api_keys (
    id character varying(36) NOT NULL,
    "userId" uuid NOT NULL,
    label character varying(100) NOT NULL,
    "apiKey" character varying NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    scopes json,
    audience character varying DEFAULT 'public-api'::character varying NOT NULL
);


ALTER TABLE public.user_api_keys OWNER TO widip;

--
-- Name: user_token_usage; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.user_token_usage (
    usage_id integer NOT NULL,
    user_id integer,
    month date NOT NULL,
    used_tokens bigint DEFAULT 0,
    quota_tokens bigint DEFAULT 50000
);


ALTER TABLE public.user_token_usage OWNER TO widip;

--
-- Name: TABLE user_token_usage; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON TABLE public.user_token_usage IS 'Compteur tokens mensuel par utilisateur';


--
-- Name: user_token_usage_usage_id_seq; Type: SEQUENCE; Schema: public; Owner: widip
--

CREATE SEQUENCE public.user_token_usage_usage_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_token_usage_usage_id_seq OWNER TO widip;

--
-- Name: user_token_usage_usage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: widip
--

ALTER SEQUENCE public.user_token_usage_usage_id_seq OWNED BY public.user_token_usage.usage_id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    username character varying(100) NOT NULL,
    password_hash character varying(255) NOT NULL,
    email character varying(255),
    role character varying(50) DEFAULT 'user'::character varying,
    created_at timestamp without time zone DEFAULT now(),
    is_active boolean DEFAULT true
);


ALTER TABLE public.users OWNER TO widip;

--
-- Name: TABLE users; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON TABLE public.users IS 'Utilisateurs WIBOT';


--
-- Name: COLUMN users.password_hash; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.users.password_hash IS 'Hash bcrypt du mot de passe';


--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: widip
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_user_id_seq OWNER TO widip;

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: widip
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: variables; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.variables (
    key character varying(50) NOT NULL,
    type character varying(50) DEFAULT 'string'::character varying NOT NULL,
    value character varying(255),
    id character varying(36) NOT NULL,
    "projectId" character varying(36)
);


ALTER TABLE public.variables OWNER TO widip;

--
-- Name: webhook_entity; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.webhook_entity (
    "webhookPath" character varying NOT NULL,
    method character varying NOT NULL,
    node character varying NOT NULL,
    "webhookId" character varying,
    "pathLength" integer,
    "workflowId" character varying(36) NOT NULL
);


ALTER TABLE public.webhook_entity OWNER TO widip;

--
-- Name: workflow_dependency; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.workflow_dependency (
    id integer NOT NULL,
    "workflowId" character varying(36) NOT NULL,
    "workflowVersionId" integer NOT NULL,
    "dependencyType" character varying(32) NOT NULL,
    "dependencyKey" character varying(255) NOT NULL,
    "dependencyInfo" json,
    "indexVersionId" smallint DEFAULT 1 NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.workflow_dependency OWNER TO widip;

--
-- Name: COLUMN workflow_dependency."workflowVersionId"; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.workflow_dependency."workflowVersionId" IS 'Version of the workflow';


--
-- Name: COLUMN workflow_dependency."dependencyType"; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.workflow_dependency."dependencyType" IS 'Type of dependency: "credential", "nodeType", "webhookPath", or "workflowCall"';


--
-- Name: COLUMN workflow_dependency."dependencyKey"; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.workflow_dependency."dependencyKey" IS 'ID or name of the dependency';


--
-- Name: COLUMN workflow_dependency."dependencyInfo"; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.workflow_dependency."dependencyInfo" IS 'Additional info about the dependency, interpreted based on type';


--
-- Name: COLUMN workflow_dependency."indexVersionId"; Type: COMMENT; Schema: public; Owner: widip
--

COMMENT ON COLUMN public.workflow_dependency."indexVersionId" IS 'Version of the index structure';


--
-- Name: workflow_dependency_id_seq; Type: SEQUENCE; Schema: public; Owner: widip
--

ALTER TABLE public.workflow_dependency ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.workflow_dependency_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: workflow_entity; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.workflow_entity (
    name character varying(128) NOT NULL,
    active boolean NOT NULL,
    nodes json NOT NULL,
    connections json NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    settings json,
    "staticData" json,
    "pinData" json,
    "versionId" character(36) NOT NULL,
    "triggerCount" integer DEFAULT 0 NOT NULL,
    id character varying(36) NOT NULL,
    meta json,
    "parentFolderId" character varying(36) DEFAULT NULL::character varying,
    "isArchived" boolean DEFAULT false NOT NULL,
    "versionCounter" integer DEFAULT 1 NOT NULL,
    description text,
    "activeVersionId" character varying(36)
);


ALTER TABLE public.workflow_entity OWNER TO widip;

--
-- Name: workflow_history; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.workflow_history (
    "versionId" character varying(36) NOT NULL,
    "workflowId" character varying(36) NOT NULL,
    authors character varying(255) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    nodes json NOT NULL,
    connections json NOT NULL,
    name character varying(128),
    autosaved boolean DEFAULT false NOT NULL,
    description text
);


ALTER TABLE public.workflow_history OWNER TO widip;

--
-- Name: workflow_statistics; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.workflow_statistics (
    count integer DEFAULT 0,
    "latestEvent" timestamp(3) with time zone,
    name character varying(128) NOT NULL,
    "workflowId" character varying(36) NOT NULL,
    "rootCount" integer DEFAULT 0
);


ALTER TABLE public.workflow_statistics OWNER TO widip;

--
-- Name: workflows_tags; Type: TABLE; Schema: public; Owner: widip
--

CREATE TABLE public.workflows_tags (
    "workflowId" character varying(36) NOT NULL,
    "tagId" character varying(36) NOT NULL
);


ALTER TABLE public.workflows_tags OWNER TO widip;

--
-- Name: auth_provider_sync_history id; Type: DEFAULT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.auth_provider_sync_history ALTER COLUMN id SET DEFAULT nextval('public.auth_provider_sync_history_id_seq'::regclass);


--
-- Name: execution_annotations id; Type: DEFAULT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.execution_annotations ALTER COLUMN id SET DEFAULT nextval('public.execution_annotations_id_seq'::regclass);


--
-- Name: execution_entity id; Type: DEFAULT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.execution_entity ALTER COLUMN id SET DEFAULT nextval('public.execution_entity_id_seq'::regclass);


--
-- Name: execution_metadata id; Type: DEFAULT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.execution_metadata ALTER COLUMN id SET DEFAULT nextval('public.execution_metadata_temp_id_seq'::regclass);


--
-- Name: messages message_id; Type: DEFAULT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.messages ALTER COLUMN message_id SET DEFAULT nextval('public.messages_message_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: n8n_chat_histories id; Type: DEFAULT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.n8n_chat_histories ALTER COLUMN id SET DEFAULT nextval('public.n8n_chat_histories_id_seq'::regclass);


--
-- Name: user_token_usage usage_id; Type: DEFAULT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.user_token_usage ALTER COLUMN usage_id SET DEFAULT nextval('public.user_token_usage_usage_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Data for Name: annotation_tag_entity; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.annotation_tag_entity (id, name, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: auth_identity; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.auth_identity ("userId", "providerId", "providerType", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: auth_provider_sync_history; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.auth_provider_sync_history (id, "providerType", "runMode", status, "startedAt", "endedAt", scanned, created, updated, disabled, error) FROM stdin;
\.


--
-- Data for Name: binary_data; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.binary_data ("fileId", "sourceType", "sourceId", data, "mimeType", "fileName", "fileSize", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: chat_hub_agents; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.chat_hub_agents (id, name, description, "systemPrompt", "ownerId", "credentialId", provider, model, "createdAt", "updatedAt", tools) FROM stdin;
\.


--
-- Data for Name: chat_hub_messages; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.chat_hub_messages (id, "sessionId", "previousMessageId", "revisionOfMessageId", "retryOfMessageId", type, name, content, provider, model, "workflowId", "executionId", "createdAt", "updatedAt", "agentId", status, attachments) FROM stdin;
\.


--
-- Data for Name: chat_hub_sessions; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.chat_hub_sessions (id, title, "ownerId", "lastMessageAt", "credentialId", provider, model, "workflowId", "createdAt", "updatedAt", "agentId", "agentName", tools) FROM stdin;
\.


--
-- Data for Name: conversations; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.conversations (conversation_id, user_id, title, created_at, updated_at) FROM stdin;
3cc2c8db-afef-4637-accc-31d259f53857	1	saluty	2025-12-26 16:43:14.778311	2025-12-26 16:45:24.684638
550e8400-e29b-41d4-a716-446655440000	1	Conversation de test	2025-12-24 07:42:15.248794	2025-12-26 17:28:13.516037
963eb9f1-fdcc-4cd5-918b-29fae40c17a0	1	quel est le chiffre important que je t'ai donné ?	2025-12-26 16:45:37.418661	2025-12-26 17:34:13.429134
419ba4c9-f14d-4af2-83b3-ba2399c17ffb	1	tu es tristes ?	2025-12-26 18:02:55.913909	2025-12-26 18:02:55.913909
\.


--
-- Data for Name: credentials_entity; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.credentials_entity (name, data, type, "createdAt", "updatedAt", id, "isManaged", "isGlobal") FROM stdin;
Mistral API	U2FsdGVkX19Z3BW3AMsDd0VNRbBX/vXV/O2ewtF801jHI6swIgOOxY7zuDpQyTE6LGBqypTRqJqO7EhXYrXaFw==	mistralCloudApi	2025-12-26 07:45:05.04+00	2025-12-26 07:45:05.039+00	b9hl3JA2taufCYVr	f	f
WIBOT PostgreSQL	U2FsdGVkX1+paHudBh/UOpu5jzZ6Zx6am+jnSEFRpI44cGKTJeDtc09drKcpTlUN0KY2n3bv6HdnbPxABjKEx8nW5X1G3JMzA0lP4ACUYrD7nuIrPqfkLC7sRjFRTBs07QTHewPDAw74vPlyvbfv5g==	postgres	2025-12-26 07:46:04.383+00	2025-12-26 07:46:04.382+00	yY2GzRzLXTG4anFZ	f	f
Ollama account	U2FsdGVkX19vmdbMb3FtVWd+qzgLh2CyH0ulrCierRw=	ollamaApi	2025-12-26 08:58:11.402+00	2025-12-26 08:58:11.401+00	Wzf3r27D8BuEckRY	f	f
\.


--
-- Data for Name: data_table; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.data_table (id, name, "projectId", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: data_table_column; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.data_table_column (id, name, type, index, "dataTableId", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: event_destinations; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.event_destinations (id, destination, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: execution_annotation_tags; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.execution_annotation_tags ("annotationId", "tagId") FROM stdin;
\.


--
-- Data for Name: execution_annotations; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.execution_annotations (id, "executionId", vote, note, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: execution_data; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.execution_data ("executionId", "workflowData", data) FROM stdin;
74	{"id":"zZSHB9BHjR30ThPP","name":"WIBOT - Auth Login","active":true,"activeVersionId":"1e31f7d7-5e68-47eb-863c-91d1ec7b0819","isArchived":false,"createdAt":"2025-12-26T17:23:18.804Z","updatedAt":"2025-12-26T17:24:10.395Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"POST","path":"auth/login","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"c8898033-10a2-436a-915d-a01f108756c6","name":"Webhook Login","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-1104,208],"webhookId":"auth-login"},{"parameters":{"resource":"database","operation":"select","schema":"public","table":"users","returnAll":false,"limit":1,"where":{"values":[{"column":"username","condition":"equal","value":"={{ $json.body.username }}"},{"column":"is_active","condition":"equal","value":"true"}]},"combineConditions":"AND","sort":{},"options":{}},"id":"a2a158de-b676-468b-a23e-18466966d674","name":"Get User","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[-880,208],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-user-exists","leftValue":"={{ $json.user_id }}","rightValue":"","operator":{"type":"exists","operation":"exists"}}],"combinator":"and"},"options":{}},"id":"dd3f022d-09ed-47fe-ba59-73ae33165762","name":"User Exists?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-656,208]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const inputPassword = $('Webhook Login').first().json.body.password;\\nconst storedHash = $input.first().json.password_hash;\\nconst user = $input.first().json;\\n\\n// Comparaison simple du mot de passe\\nconst isValid = (inputPassword === storedHash);\\n\\nreturn [{ json: { isValid, user } }];","notice":""},"id":"bb41f913-1c3c-4afb-88a4-c46324c2b9ec","name":"Verify Password","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-password-valid","leftValue":"={{ $json.isValid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"73c0896e-95a9-4677-86c9-3398d7856fad","name":"Password Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const user = $input.first().json.user;\\n\\n// Fonction base64 encode compatible n8n\\nfunction toBase64(str) {\\n  return Buffer.from(str).toString('base64').replace(/=/g, '').replace(/\\\\+/g, '-').replace(/\\\\//g, '_');\\n}\\n\\nconst header = toBase64(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));\\n\\nconst payload = toBase64(JSON.stringify({\\n  userId: user.user_id,\\n  username: user.username,\\n  role: user.role,\\n  iat: Math.floor(Date.now() / 1000),\\n  exp: Math.floor(Date.now() / 1000) + (24 * 60 * 60)\\n}));\\n\\n// Signature simplifiée\\nconst signature = toBase64(header + payload + 'wibot_secret').substring(0, 43);\\n\\nconst token = `${header}.${payload}.${signature}`;\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    token,\\n    user: {\\n      id: user.user_id,\\n      username: user.username,\\n      role: user.role\\n    }\\n  }\\n}];","notice":""},"id":"56756190-1aeb-4413-946a-e2a7b4907e8e","name":"Generate JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[0,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"5e5d60cc-5fee-4f26-b838-71d66c7a885a","name":"Success Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[224,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"Invalid credentials\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"e90d3bbc-527a-4b00-b1dc-9bb17afa5966","name":"Invalid Password","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,208]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"User not found\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"8423d2d4-a607-49d0-a6d7-8730cf78fd86","name":"User Not Found","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[-448,304]}],"connections":{"Webhook Login":{"main":[[{"node":"Get User","type":"main","index":0}]]},"Get User":{"main":[[{"node":"User Exists?","type":"main","index":0}]]},"User Exists?":{"main":[[{"node":"Verify Password","type":"main","index":0}],[{"node":"User Not Found","type":"main","index":0}]]},"Verify Password":{"main":[[{"node":"Password Valid?","type":"main","index":0}]]},"Password Valid?":{"main":[[{"node":"Generate JWT","type":"main","index":0}],[{"node":"Invalid Password","type":"main","index":0}]]},"Generate JWT":{"main":[[{"node":"Success Response","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook Login":"12","Get User":"13","User Exists?":"14","Verify Password":"15","Password Valid?":"16","Generate JWT":"17","Success Response":"18"},"Success Response",{},[],{},{},{},{"version":1,"establishedAt":1766769892380,"source":"19"},["20"],["21"],["22"],["23"],["24"],["25"],["26"],"webhook",{"startTime":1766769892380,"executionIndex":0,"source":"27","hints":"28","executionTime":0,"executionStatus":"29","data":"30"},{"startTime":1766769892380,"executionIndex":1,"source":"31","hints":"32","executionTime":8,"executionStatus":"29","data":"33"},{"startTime":1766769892388,"executionIndex":2,"source":"34","hints":"35","executionTime":1,"executionStatus":"29","data":"36"},{"startTime":1766769892389,"executionIndex":3,"source":"37","hints":"38","executionTime":2,"executionStatus":"29","data":"39"},{"startTime":1766769892391,"executionIndex":4,"source":"40","hints":"41","executionTime":1,"executionStatus":"29","data":"42"},{"startTime":1766769892392,"executionIndex":5,"source":"43","hints":"44","executionTime":2,"executionStatus":"29","data":"45"},{"startTime":1766769892394,"executionIndex":6,"source":"46","hints":"47","executionTime":0,"executionStatus":"29","data":"48"},[],[],"success",{"main":"49"},["50"],[],{"main":"51"},["52"],[],{"main":"53"},["54"],["55"],{"main":"56"},["57"],[],{"main":"58"},["59"],["60"],{"main":"61"},["62"],[],{"main":"63"},["64"],{"previousNode":"65"},["66"],{"previousNode":"67"},["68","69"],{"previousNode":"70"},{"message":"71","location":"72"},["73"],{"previousNode":"74"},["75","76"],{"previousNode":"77"},{"message":"71","location":"72"},["78"],{"previousNode":"79"},["80"],["81"],"Webhook Login",["82"],"Get User",["83"],[],"User Exists?","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["84"],"Verify Password",["85"],[],"Password Valid?",["86"],"Generate JWT",["87"],{"json":"88","pairedItem":"89"},{"json":"90","pairedItem":"91"},{"json":"90","pairedItem":"92"},{"json":"93","pairedItem":"94"},{"json":"93","pairedItem":"95"},{"json":"96","pairedItem":"97"},{"json":"96","pairedItem":"98"},{"headers":"99","params":"100","query":"101","body":"102","webhookUrl":"103","executionMode":"104"},{"item":0},{"user_id":1,"username":"105","password_hash":"106","email":"107","role":"108","created_at":"109","is_active":true},{"item":0},{"item":0},{"isValid":true,"user":"110"},{"item":0},{"item":0},{"success":true,"token":"111","user":"112"},{"item":0},{"item":0},{"host":"113","x-real-ip":"114","x-forwarded-for":"114","x-forwarded-proto":"115","connection":"116","content-length":"117","sec-ch-ua-platform":"118","user-agent":"119","accept":"120","sec-ch-ua":"121","content-type":"122","dnt":"123","sec-ch-ua-mobile":"124","origin":"125","sec-fetch-site":"126","sec-fetch-mode":"127","sec-fetch-dest":"128","referer":"129","accept-encoding":"130","accept-language":"131","sec-gpc":"123"},{},{},{"username":"105","password":"106"},"http://localhost:5678/webhook/auth/login","production","khora","test123","khora@widip.fr","admin","2025-12-26T06:42:15.244Z",{"user_id":1,"username":"105","password_hash":"106","email":"107","role":"108","created_at":"109","is_active":true},"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3Njk4OTIsImV4cCI6MTc2Njg1NjI5Mn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh",{"id":1,"username":"105","role":"108"},"localhost","172.20.0.1","http","close","41","\\"Windows\\"","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","application/json","1","?0","http://localhost:5173","same-site","cors","empty","http://localhost:5173/","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7"]
75	{"id":"zZSHB9BHjR30ThPP","name":"WIBOT - Auth Login","active":true,"activeVersionId":"1e31f7d7-5e68-47eb-863c-91d1ec7b0819","isArchived":false,"createdAt":"2025-12-26T17:23:18.804Z","updatedAt":"2025-12-26T17:24:10.395Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"POST","path":"auth/login","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"c8898033-10a2-436a-915d-a01f108756c6","name":"Webhook Login","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-1104,208],"webhookId":"auth-login"},{"parameters":{"resource":"database","operation":"select","schema":"public","table":"users","returnAll":false,"limit":1,"where":{"values":[{"column":"username","condition":"equal","value":"={{ $json.body.username }}"},{"column":"is_active","condition":"equal","value":"true"}]},"combineConditions":"AND","sort":{},"options":{}},"id":"a2a158de-b676-468b-a23e-18466966d674","name":"Get User","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[-880,208],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-user-exists","leftValue":"={{ $json.user_id }}","rightValue":"","operator":{"type":"exists","operation":"exists"}}],"combinator":"and"},"options":{}},"id":"dd3f022d-09ed-47fe-ba59-73ae33165762","name":"User Exists?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-656,208]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const inputPassword = $('Webhook Login').first().json.body.password;\\nconst storedHash = $input.first().json.password_hash;\\nconst user = $input.first().json;\\n\\n// Comparaison simple du mot de passe\\nconst isValid = (inputPassword === storedHash);\\n\\nreturn [{ json: { isValid, user } }];","notice":""},"id":"bb41f913-1c3c-4afb-88a4-c46324c2b9ec","name":"Verify Password","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-password-valid","leftValue":"={{ $json.isValid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"73c0896e-95a9-4677-86c9-3398d7856fad","name":"Password Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const user = $input.first().json.user;\\n\\n// Fonction base64 encode compatible n8n\\nfunction toBase64(str) {\\n  return Buffer.from(str).toString('base64').replace(/=/g, '').replace(/\\\\+/g, '-').replace(/\\\\//g, '_');\\n}\\n\\nconst header = toBase64(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));\\n\\nconst payload = toBase64(JSON.stringify({\\n  userId: user.user_id,\\n  username: user.username,\\n  role: user.role,\\n  iat: Math.floor(Date.now() / 1000),\\n  exp: Math.floor(Date.now() / 1000) + (24 * 60 * 60)\\n}));\\n\\n// Signature simplifiée\\nconst signature = toBase64(header + payload + 'wibot_secret').substring(0, 43);\\n\\nconst token = `${header}.${payload}.${signature}`;\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    token,\\n    user: {\\n      id: user.user_id,\\n      username: user.username,\\n      role: user.role\\n    }\\n  }\\n}];","notice":""},"id":"56756190-1aeb-4413-946a-e2a7b4907e8e","name":"Generate JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[0,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"5e5d60cc-5fee-4f26-b838-71d66c7a885a","name":"Success Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[224,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"Invalid credentials\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"e90d3bbc-527a-4b00-b1dc-9bb17afa5966","name":"Invalid Password","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,208]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"User not found\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"8423d2d4-a607-49d0-a6d7-8730cf78fd86","name":"User Not Found","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[-448,304]}],"connections":{"Webhook Login":{"main":[[{"node":"Get User","type":"main","index":0}]]},"Get User":{"main":[[{"node":"User Exists?","type":"main","index":0}]]},"User Exists?":{"main":[[{"node":"Verify Password","type":"main","index":0}],[{"node":"User Not Found","type":"main","index":0}]]},"Verify Password":{"main":[[{"node":"Password Valid?","type":"main","index":0}]]},"Password Valid?":{"main":[[{"node":"Generate JWT","type":"main","index":0}],[{"node":"Invalid Password","type":"main","index":0}]]},"Generate JWT":{"main":[[{"node":"Success Response","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook Login":"12","Get User":"13","User Exists?":"14","Verify Password":"15","Password Valid?":"16","Generate JWT":"17","Success Response":"18"},"Success Response",{},[],{},{},{},{"version":1,"establishedAt":1766769943180,"source":"19"},["20"],["21"],["22"],["23"],["24"],["25"],["26"],"webhook",{"startTime":1766769943181,"executionIndex":0,"source":"27","hints":"28","executionTime":0,"executionStatus":"29","data":"30"},{"startTime":1766769943181,"executionIndex":1,"source":"31","hints":"32","executionTime":7,"executionStatus":"29","data":"33"},{"startTime":1766769943188,"executionIndex":2,"source":"34","hints":"35","executionTime":0,"executionStatus":"29","data":"36"},{"startTime":1766769943188,"executionIndex":3,"source":"37","hints":"38","executionTime":2,"executionStatus":"29","data":"39"},{"startTime":1766769943191,"executionIndex":4,"source":"40","hints":"41","executionTime":0,"executionStatus":"29","data":"42"},{"startTime":1766769943191,"executionIndex":5,"source":"43","hints":"44","executionTime":3,"executionStatus":"29","data":"45"},{"startTime":1766769943194,"executionIndex":6,"source":"46","hints":"47","executionTime":1,"executionStatus":"29","data":"48"},[],[],"success",{"main":"49"},["50"],[],{"main":"51"},["52"],[],{"main":"53"},["54"],["55"],{"main":"56"},["57"],[],{"main":"58"},["59"],["60"],{"main":"61"},["62"],[],{"main":"63"},["64"],{"previousNode":"65"},["66"],{"previousNode":"67"},["68","69"],{"previousNode":"70"},{"message":"71","location":"72"},["73"],{"previousNode":"74"},["75","76"],{"previousNode":"77"},{"message":"71","location":"72"},["78"],{"previousNode":"79"},["80"],["81"],"Webhook Login",["82"],"Get User",["83"],[],"User Exists?","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["84"],"Verify Password",["85"],[],"Password Valid?",["86"],"Generate JWT",["87"],{"json":"88","pairedItem":"89"},{"json":"90","pairedItem":"91"},{"json":"90","pairedItem":"92"},{"json":"93","pairedItem":"94"},{"json":"93","pairedItem":"95"},{"json":"96","pairedItem":"97"},{"json":"96","pairedItem":"98"},{"headers":"99","params":"100","query":"101","body":"102","webhookUrl":"103","executionMode":"104"},{"item":0},{"user_id":1,"username":"105","password_hash":"106","email":"107","role":"108","created_at":"109","is_active":true},{"item":0},{"item":0},{"isValid":true,"user":"110"},{"item":0},{"item":0},{"success":true,"token":"111","user":"112"},{"item":0},{"item":0},{"host":"113","x-real-ip":"114","x-forwarded-for":"114","x-forwarded-proto":"115","connection":"116","content-length":"117","sec-ch-ua-platform":"118","user-agent":"119","accept":"120","sec-ch-ua":"121","content-type":"122","dnt":"123","sec-ch-ua-mobile":"124","origin":"125","sec-fetch-site":"126","sec-fetch-mode":"127","sec-fetch-dest":"128","referer":"129","accept-encoding":"130","accept-language":"131","sec-gpc":"123"},{},{},{"username":"105","password":"106"},"http://localhost:5678/webhook/auth/login","production","khora","test123","khora@widip.fr","admin","2025-12-26T06:42:15.244Z",{"user_id":1,"username":"105","password_hash":"106","email":"107","role":"108","created_at":"109","is_active":true},"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3Njk5NDMsImV4cCI6MTc2Njg1NjM0M30.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh",{"id":1,"username":"105","role":"108"},"localhost","172.20.0.1","http","close","41","\\"Windows\\"","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","application/json","1","?0","http://localhost:5173","same-site","cors","empty","http://localhost:5173/","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7"]
76	{"id":"zZSHB9BHjR30ThPP","name":"WIBOT - Auth Login","active":true,"activeVersionId":"1e31f7d7-5e68-47eb-863c-91d1ec7b0819","isArchived":false,"createdAt":"2025-12-26T17:23:18.804Z","updatedAt":"2025-12-26T17:24:10.395Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"POST","path":"auth/login","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"c8898033-10a2-436a-915d-a01f108756c6","name":"Webhook Login","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-1104,208],"webhookId":"auth-login"},{"parameters":{"resource":"database","operation":"select","schema":"public","table":"users","returnAll":false,"limit":1,"where":{"values":[{"column":"username","condition":"equal","value":"={{ $json.body.username }}"},{"column":"is_active","condition":"equal","value":"true"}]},"combineConditions":"AND","sort":{},"options":{}},"id":"a2a158de-b676-468b-a23e-18466966d674","name":"Get User","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[-880,208],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-user-exists","leftValue":"={{ $json.user_id }}","rightValue":"","operator":{"type":"exists","operation":"exists"}}],"combinator":"and"},"options":{}},"id":"dd3f022d-09ed-47fe-ba59-73ae33165762","name":"User Exists?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-656,208]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const inputPassword = $('Webhook Login').first().json.body.password;\\nconst storedHash = $input.first().json.password_hash;\\nconst user = $input.first().json;\\n\\n// Comparaison simple du mot de passe\\nconst isValid = (inputPassword === storedHash);\\n\\nreturn [{ json: { isValid, user } }];","notice":""},"id":"bb41f913-1c3c-4afb-88a4-c46324c2b9ec","name":"Verify Password","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-password-valid","leftValue":"={{ $json.isValid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"73c0896e-95a9-4677-86c9-3398d7856fad","name":"Password Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const user = $input.first().json.user;\\n\\n// Fonction base64 encode compatible n8n\\nfunction toBase64(str) {\\n  return Buffer.from(str).toString('base64').replace(/=/g, '').replace(/\\\\+/g, '-').replace(/\\\\//g, '_');\\n}\\n\\nconst header = toBase64(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));\\n\\nconst payload = toBase64(JSON.stringify({\\n  userId: user.user_id,\\n  username: user.username,\\n  role: user.role,\\n  iat: Math.floor(Date.now() / 1000),\\n  exp: Math.floor(Date.now() / 1000) + (24 * 60 * 60)\\n}));\\n\\n// Signature simplifiée\\nconst signature = toBase64(header + payload + 'wibot_secret').substring(0, 43);\\n\\nconst token = `${header}.${payload}.${signature}`;\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    token,\\n    user: {\\n      id: user.user_id,\\n      username: user.username,\\n      role: user.role\\n    }\\n  }\\n}];","notice":""},"id":"56756190-1aeb-4413-946a-e2a7b4907e8e","name":"Generate JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[0,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"5e5d60cc-5fee-4f26-b838-71d66c7a885a","name":"Success Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[224,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"Invalid credentials\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"e90d3bbc-527a-4b00-b1dc-9bb17afa5966","name":"Invalid Password","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,208]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"User not found\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"8423d2d4-a607-49d0-a6d7-8730cf78fd86","name":"User Not Found","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[-448,304]}],"connections":{"Webhook Login":{"main":[[{"node":"Get User","type":"main","index":0}]]},"Get User":{"main":[[{"node":"User Exists?","type":"main","index":0}]]},"User Exists?":{"main":[[{"node":"Verify Password","type":"main","index":0}],[{"node":"User Not Found","type":"main","index":0}]]},"Verify Password":{"main":[[{"node":"Password Valid?","type":"main","index":0}]]},"Password Valid?":{"main":[[{"node":"Generate JWT","type":"main","index":0}],[{"node":"Invalid Password","type":"main","index":0}]]},"Generate JWT":{"main":[[{"node":"Success Response","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook Login":"12","Get User":"13","User Exists?":"14","Verify Password":"15","Password Valid?":"16","Generate JWT":"17","Success Response":"18"},"Success Response",{},[],{},{},{},{"version":1,"establishedAt":1766769958378,"source":"19"},["20"],["21"],["22"],["23"],["24"],["25"],["26"],"webhook",{"startTime":1766769958378,"executionIndex":0,"source":"27","hints":"28","executionTime":0,"executionStatus":"29","data":"30"},{"startTime":1766769958378,"executionIndex":1,"source":"31","hints":"32","executionTime":7,"executionStatus":"29","data":"33"},{"startTime":1766769958385,"executionIndex":2,"source":"34","hints":"35","executionTime":0,"executionStatus":"29","data":"36"},{"startTime":1766769958385,"executionIndex":3,"source":"37","hints":"38","executionTime":2,"executionStatus":"29","data":"39"},{"startTime":1766769958388,"executionIndex":4,"source":"40","hints":"41","executionTime":0,"executionStatus":"29","data":"42"},{"startTime":1766769958388,"executionIndex":5,"source":"43","hints":"44","executionTime":3,"executionStatus":"29","data":"45"},{"startTime":1766769958391,"executionIndex":6,"source":"46","hints":"47","executionTime":0,"executionStatus":"29","data":"48"},[],[],"success",{"main":"49"},["50"],[],{"main":"51"},["52"],[],{"main":"53"},["54"],["55"],{"main":"56"},["57"],[],{"main":"58"},["59"],["60"],{"main":"61"},["62"],[],{"main":"63"},["64"],{"previousNode":"65"},["66"],{"previousNode":"67"},["68","69"],{"previousNode":"70"},{"message":"71","location":"72"},["73"],{"previousNode":"74"},["75","76"],{"previousNode":"77"},{"message":"71","location":"72"},["78"],{"previousNode":"79"},["80"],["81"],"Webhook Login",["82"],"Get User",["83"],[],"User Exists?","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["84"],"Verify Password",["85"],[],"Password Valid?",["86"],"Generate JWT",["87"],{"json":"88","pairedItem":"89"},{"json":"90","pairedItem":"91"},{"json":"90","pairedItem":"92"},{"json":"93","pairedItem":"94"},{"json":"93","pairedItem":"95"},{"json":"96","pairedItem":"97"},{"json":"96","pairedItem":"98"},{"headers":"99","params":"100","query":"101","body":"102","webhookUrl":"103","executionMode":"104"},{"item":0},{"user_id":1,"username":"105","password_hash":"106","email":"107","role":"108","created_at":"109","is_active":true},{"item":0},{"item":0},{"isValid":true,"user":"110"},{"item":0},{"item":0},{"success":true,"token":"111","user":"112"},{"item":0},{"item":0},{"host":"113","x-real-ip":"114","x-forwarded-for":"114","x-forwarded-proto":"115","connection":"116","content-length":"117","user-agent":"118","accept":"119","content-type":"120"},{},{},{"username":"105","password":"106"},"http://localhost:5678/webhook/auth/login","production","khora","test123","khora@widip.fr","admin","2025-12-26T06:42:15.244Z",{"user_id":1,"username":"105","password_hash":"106","email":"107","role":"108","created_at":"109","is_active":true},"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3Njk5NTgsImV4cCI6MTc2Njg1NjM1OH0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh",{"id":1,"username":"105","role":"108"},"localhost","172.20.0.1","http","close","41","curl/8.12.1","*/*","application/json"]
77	{"id":"zZSHB9BHjR30ThPP","name":"WIBOT - Auth Login","active":true,"activeVersionId":"1e31f7d7-5e68-47eb-863c-91d1ec7b0819","isArchived":false,"createdAt":"2025-12-26T17:23:18.804Z","updatedAt":"2025-12-26T17:24:10.395Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"POST","path":"auth/login","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"c8898033-10a2-436a-915d-a01f108756c6","name":"Webhook Login","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-1104,208],"webhookId":"auth-login"},{"parameters":{"resource":"database","operation":"select","schema":"public","table":"users","returnAll":false,"limit":1,"where":{"values":[{"column":"username","condition":"equal","value":"={{ $json.body.username }}"},{"column":"is_active","condition":"equal","value":"true"}]},"combineConditions":"AND","sort":{},"options":{}},"id":"a2a158de-b676-468b-a23e-18466966d674","name":"Get User","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[-880,208],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-user-exists","leftValue":"={{ $json.user_id }}","rightValue":"","operator":{"type":"exists","operation":"exists"}}],"combinator":"and"},"options":{}},"id":"dd3f022d-09ed-47fe-ba59-73ae33165762","name":"User Exists?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-656,208]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const inputPassword = $('Webhook Login').first().json.body.password;\\nconst storedHash = $input.first().json.password_hash;\\nconst user = $input.first().json;\\n\\n// Comparaison simple du mot de passe\\nconst isValid = (inputPassword === storedHash);\\n\\nreturn [{ json: { isValid, user } }];","notice":""},"id":"bb41f913-1c3c-4afb-88a4-c46324c2b9ec","name":"Verify Password","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-password-valid","leftValue":"={{ $json.isValid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"73c0896e-95a9-4677-86c9-3398d7856fad","name":"Password Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const user = $input.first().json.user;\\n\\n// Fonction base64 encode compatible n8n\\nfunction toBase64(str) {\\n  return Buffer.from(str).toString('base64').replace(/=/g, '').replace(/\\\\+/g, '-').replace(/\\\\//g, '_');\\n}\\n\\nconst header = toBase64(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));\\n\\nconst payload = toBase64(JSON.stringify({\\n  userId: user.user_id,\\n  username: user.username,\\n  role: user.role,\\n  iat: Math.floor(Date.now() / 1000),\\n  exp: Math.floor(Date.now() / 1000) + (24 * 60 * 60)\\n}));\\n\\n// Signature simplifiée\\nconst signature = toBase64(header + payload + 'wibot_secret').substring(0, 43);\\n\\nconst token = `${header}.${payload}.${signature}`;\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    token,\\n    user: {\\n      id: user.user_id,\\n      username: user.username,\\n      role: user.role\\n    }\\n  }\\n}];","notice":""},"id":"56756190-1aeb-4413-946a-e2a7b4907e8e","name":"Generate JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[0,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"5e5d60cc-5fee-4f26-b838-71d66c7a885a","name":"Success Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[224,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"Invalid credentials\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"e90d3bbc-527a-4b00-b1dc-9bb17afa5966","name":"Invalid Password","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,208]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"User not found\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"8423d2d4-a607-49d0-a6d7-8730cf78fd86","name":"User Not Found","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[-448,304]}],"connections":{"Webhook Login":{"main":[[{"node":"Get User","type":"main","index":0}]]},"Get User":{"main":[[{"node":"User Exists?","type":"main","index":0}]]},"User Exists?":{"main":[[{"node":"Verify Password","type":"main","index":0}],[{"node":"User Not Found","type":"main","index":0}]]},"Verify Password":{"main":[[{"node":"Password Valid?","type":"main","index":0}]]},"Password Valid?":{"main":[[{"node":"Generate JWT","type":"main","index":0}],[{"node":"Invalid Password","type":"main","index":0}]]},"Generate JWT":{"main":[[{"node":"Success Response","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook Login":"12","Get User":"13","User Exists?":"14","Verify Password":"15","Password Valid?":"16","Generate JWT":"17","Success Response":"18"},"Success Response",{},[],{},{},{},{"version":1,"establishedAt":1766770086001,"source":"19"},["20"],["21"],["22"],["23"],["24"],["25"],["26"],"webhook",{"startTime":1766770086002,"executionIndex":0,"source":"27","hints":"28","executionTime":0,"executionStatus":"29","data":"30"},{"startTime":1766770086002,"executionIndex":1,"source":"31","hints":"32","executionTime":7,"executionStatus":"29","data":"33"},{"startTime":1766770086009,"executionIndex":2,"source":"34","hints":"35","executionTime":0,"executionStatus":"29","data":"36"},{"startTime":1766770086009,"executionIndex":3,"source":"37","hints":"38","executionTime":2,"executionStatus":"29","data":"39"},{"startTime":1766770086012,"executionIndex":4,"source":"40","hints":"41","executionTime":0,"executionStatus":"29","data":"42"},{"startTime":1766770086012,"executionIndex":5,"source":"43","hints":"44","executionTime":5,"executionStatus":"29","data":"45"},{"startTime":1766770086017,"executionIndex":6,"source":"46","hints":"47","executionTime":0,"executionStatus":"29","data":"48"},[],[],"success",{"main":"49"},["50"],[],{"main":"51"},["52"],[],{"main":"53"},["54"],["55"],{"main":"56"},["57"],[],{"main":"58"},["59"],["60"],{"main":"61"},["62"],[],{"main":"63"},["64"],{"previousNode":"65"},["66"],{"previousNode":"67"},["68","69"],{"previousNode":"70"},{"message":"71","location":"72"},["73"],{"previousNode":"74"},["75","76"],{"previousNode":"77"},{"message":"71","location":"72"},["78"],{"previousNode":"79"},["80"],["81"],"Webhook Login",["82"],"Get User",["83"],[],"User Exists?","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["84"],"Verify Password",["85"],[],"Password Valid?",["86"],"Generate JWT",["87"],{"json":"88","pairedItem":"89"},{"json":"90","pairedItem":"91"},{"json":"90","pairedItem":"92"},{"json":"93","pairedItem":"94"},{"json":"93","pairedItem":"95"},{"json":"96","pairedItem":"97"},{"json":"96","pairedItem":"98"},{"headers":"99","params":"100","query":"101","body":"102","webhookUrl":"103","executionMode":"104"},{"item":0},{"user_id":1,"username":"105","password_hash":"106","email":"107","role":"108","created_at":"109","is_active":true},{"item":0},{"item":0},{"isValid":true,"user":"110"},{"item":0},{"item":0},{"success":true,"token":"111","user":"112"},{"item":0},{"item":0},{"host":"113","x-real-ip":"114","x-forwarded-for":"114","x-forwarded-proto":"115","connection":"116","content-length":"117","sec-ch-ua-platform":"118","user-agent":"119","accept":"120","sec-ch-ua":"121","content-type":"122","dnt":"123","sec-ch-ua-mobile":"124","origin":"125","sec-fetch-site":"126","sec-fetch-mode":"127","sec-fetch-dest":"128","referer":"129","accept-encoding":"130","accept-language":"131","cookie":"132","sec-gpc":"123"},{},{},{"username":"105","password":"106"},"http://localhost:5678/webhook/auth/login","production","khora","test123","khora@widip.fr","admin","2025-12-26T06:42:15.244Z",{"user_id":1,"username":"105","password_hash":"106","email":"107","role":"108","created_at":"109","is_active":true},"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzAwODYsImV4cCI6MTc2Njg1NjQ4Nn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh",{"id":1,"username":"105","role":"108"},"localhost","172.20.0.1","http","close","41","\\"Windows\\"","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","application/json","1","?0","http://localhost:5173","same-origin","cors","empty","http://localhost:5173/login","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX19OCF2pwGAF9%2F1pnZFbf%2FU9bjx8bVtFQuoB8uuJ4NZsPcztnq86wTJ%2BQifiUh5ZvOQcOj%2FH3NsgdQ%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX18wdSl%2BbR3A%2BBVvQhbd%2Ft6PfsfHxsKEBaccdHn1PqgznQhdlXcvXpMucO9JmugdZAZPzPIfhheQNJAG2z4HadQI5CAOk4n%2BuIssh%2B059iyHUcXJeKi1D58q%2BCEliIFzvdt2thhgEtEAPvHTYsMEoJxnCpILtIFuLEY%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX1%2B3MJSeV1f7oHZwtV0yoKDLaJhiGtE8gWe2a%2B7YBR5%2BIzzCrIR1ldx3zHzuCpiycKrm8ZvbyAdpk7xyQpiLsCpvxYZYpvUTC17KvTIAGMDiyRCN9uYzTsmLgBICuGc946bvr7TN4sMBy%2BIBbMv55j1q%2F3bhkK1Hg58%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2FERVfhya6DPHED9AM7MdTRO7q4UT3hT67GDfzJYwdaHWTFTkAAuNcmRVwsCWWAnp19SNOZyK4oltRv5k4P7cBM1Nc7%2FlQiwgZDvuNPxkT1S4sc2MkmJXypiMtoEtKtBVezvB1%2BWlofbQ%3D%3D"]
78	{"id":"c8fbjjX9ObuzBE4b","name":"WIBOT - Get User Tokens","active":true,"activeVersionId":"62643582-5e10-4f85-9c6c-74a85d102e67","isArchived":false,"createdAt":"2025-12-26T17:24:01.471Z","updatedAt":"2025-12-26T17:24:05.529Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/user/tokens","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"8fcee23f-b3e4-4c28-ad04-4ba456f7752a","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-656,112],"webhookId":"wibot-user-tokens"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"d8de2cd5-94e4-49a5-a318-1ee1c389abd9","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"c9c309e4-53ba-46be-8960-13da82f4f5f7","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"83cd3ac8-fb46-4de5-a8ce-5d24be08334c","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  COALESCE(used_tokens, 0) as used_tokens,\\n  COALESCE(quota_tokens, 50000) as quota_tokens,\\n  COALESCE(quota_tokens, 50000) - COALESCE(used_tokens, 0) as tokens_remaining\\nFROM user_token_usage\\nWHERE user_id = {{ $json.userId }}\\n  AND month = DATE_TRUNC('month', CURRENT_DATE)\\nLIMIT 1;","options":{}},"id":"b35fa964-24c4-49ed-a3b6-7df917662ceb","name":"Get Token Usage","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[0,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\nconst jwtData = $('Verify JWT').first().json;\\n\\n// Si pas de donnees, l'utilisateur n'a pas encore utilise de tokens ce mois\\nif (!rows || rows.length === 0 || rows[0].json.tokens_remaining === undefined) {\\n  return [{\\n    json: {\\n      success: true,\\n      used_tokens: 0,\\n      quota_tokens: 50000,\\n      tokens_remaining: 50000\\n    }\\n  }];\\n}\\n\\nconst data = rows[0].json;\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    used_tokens: parseInt(data.used_tokens) || 0,\\n    quota_tokens: parseInt(data.quota_tokens) || 50000,\\n    tokens_remaining: parseInt(data.tokens_remaining) || 50000\\n  }\\n}];","notice":""},"id":"7d9b1764-6fed-49d3-957f-402aa7f05696","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"67daad4e-a2fe-4b36-b18c-065181b80de3","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[448,0]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Token Usage","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Token Usage":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Token Usage":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766770086640,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766770086640,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766770086640,"executionIndex":1,"source":"29","hints":"30","executionTime":3,"executionStatus":"27","data":"31"},{"startTime":1766770086643,"executionIndex":2,"source":"32","hints":"33","executionTime":1,"executionStatus":"27","data":"34"},{"startTime":1766770086644,"executionIndex":3,"source":"35","hints":"36","executionTime":6,"executionStatus":"27","data":"37"},{"startTime":1766770086650,"executionIndex":4,"source":"38","hints":"39","executionTime":3,"executionStatus":"27","data":"40"},{"startTime":1766770086654,"executionIndex":5,"source":"41","hints":"42","executionTime":0,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74"],"Get Token Usage",["75"],"Format Response",["76"],{"json":"77","pairedItem":"78"},{"json":"79","pairedItem":"80"},{"json":"79","pairedItem":"81"},{"json":"82","pairedItem":"83"},{"json":"84","pairedItem":"85"},{"json":"84","pairedItem":"86"},{"headers":"87","params":"88","query":"89","body":"90","webhookUrl":"91","executionMode":"92"},{"item":0},{"valid":true,"userId":1},{"item":0},{"item":0},{"used_tokens":"93","quota_tokens":"94","tokens_remaining":"95"},{"item":0},{"success":true,"used_tokens":14249,"quota_tokens":50000,"tokens_remaining":35751},{"item":0},{"item":0},{"host":"96","x-real-ip":"97","x-forwarded-for":"97","x-forwarded-proto":"98","connection":"99","sec-ch-ua-platform":"100","authorization":"101","user-agent":"102","accept":"103","sec-ch-ua":"104","dnt":"105","sec-ch-ua-mobile":"106","sec-fetch-site":"107","sec-fetch-mode":"108","sec-fetch-dest":"109","referer":"110","accept-encoding":"111","accept-language":"112","cookie":"113","sec-gpc":"105"},{},{},{},"http://localhost:5678/webhook/wibot/user/tokens","production","14249","50000","35751","localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzAwODYsImV4cCI6MTc2Njg1NjQ4Nn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX19OCF2pwGAF9%2F1pnZFbf%2FU9bjx8bVtFQuoB8uuJ4NZsPcztnq86wTJ%2BQifiUh5ZvOQcOj%2FH3NsgdQ%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX18wdSl%2BbR3A%2BBVvQhbd%2Ft6PfsfHxsKEBaccdHn1PqgznQhdlXcvXpMucO9JmugdZAZPzPIfhheQNJAG2z4HadQI5CAOk4n%2BuIssh%2B059iyHUcXJeKi1D58q%2BCEliIFzvdt2thhgEtEAPvHTYsMEoJxnCpILtIFuLEY%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX1%2B3MJSeV1f7oHZwtV0yoKDLaJhiGtE8gWe2a%2B7YBR5%2BIzzCrIR1ldx3zHzuCpiycKrm8ZvbyAdpk7xyQpiLsCpvxYZYpvUTC17KvTIAGMDiyRCN9uYzTsmLgBICuGc946bvr7TN4sMBy%2BIBbMv55j1q%2F3bhkK1Hg58%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2FERVfhya6DPHED9AM7MdTRO7q4UT3hT67GDfzJYwdaHWTFTkAAuNcmRVwsCWWAnp19SNOZyK4oltRv5k4P7cBM1Nc7%2FlQiwgZDvuNPxkT1S4sc2MkmJXypiMtoEtKtBVezvB1%2BWlofbQ%3D%3D"]
80	{"id":"c8fbjjX9ObuzBE4b","name":"WIBOT - Get User Tokens","active":true,"activeVersionId":"62643582-5e10-4f85-9c6c-74a85d102e67","isArchived":false,"createdAt":"2025-12-26T17:24:01.471Z","updatedAt":"2025-12-26T17:24:05.529Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/user/tokens","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"8fcee23f-b3e4-4c28-ad04-4ba456f7752a","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-656,112],"webhookId":"wibot-user-tokens"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"d8de2cd5-94e4-49a5-a318-1ee1c389abd9","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"c9c309e4-53ba-46be-8960-13da82f4f5f7","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"83cd3ac8-fb46-4de5-a8ce-5d24be08334c","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  COALESCE(used_tokens, 0) as used_tokens,\\n  COALESCE(quota_tokens, 50000) as quota_tokens,\\n  COALESCE(quota_tokens, 50000) - COALESCE(used_tokens, 0) as tokens_remaining\\nFROM user_token_usage\\nWHERE user_id = {{ $json.userId }}\\n  AND month = DATE_TRUNC('month', CURRENT_DATE)\\nLIMIT 1;","options":{}},"id":"b35fa964-24c4-49ed-a3b6-7df917662ceb","name":"Get Token Usage","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[0,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\nconst jwtData = $('Verify JWT').first().json;\\n\\n// Si pas de donnees, l'utilisateur n'a pas encore utilise de tokens ce mois\\nif (!rows || rows.length === 0 || rows[0].json.tokens_remaining === undefined) {\\n  return [{\\n    json: {\\n      success: true,\\n      used_tokens: 0,\\n      quota_tokens: 50000,\\n      tokens_remaining: 50000\\n    }\\n  }];\\n}\\n\\nconst data = rows[0].json;\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    used_tokens: parseInt(data.used_tokens) || 0,\\n    quota_tokens: parseInt(data.quota_tokens) || 50000,\\n    tokens_remaining: parseInt(data.tokens_remaining) || 50000\\n  }\\n}];","notice":""},"id":"7d9b1764-6fed-49d3-957f-402aa7f05696","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"67daad4e-a2fe-4b36-b18c-065181b80de3","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[448,0]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Token Usage","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Token Usage":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Token Usage":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766770086671,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766770086671,"executionIndex":0,"source":"25","hints":"26","executionTime":1,"executionStatus":"27","data":"28"},{"startTime":1766770086672,"executionIndex":1,"source":"29","hints":"30","executionTime":3,"executionStatus":"27","data":"31"},{"startTime":1766770086675,"executionIndex":2,"source":"32","hints":"33","executionTime":0,"executionStatus":"27","data":"34"},{"startTime":1766770086675,"executionIndex":3,"source":"35","hints":"36","executionTime":2,"executionStatus":"27","data":"37"},{"startTime":1766770086677,"executionIndex":4,"source":"38","hints":"39","executionTime":2,"executionStatus":"27","data":"40"},{"startTime":1766770086679,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74"],"Get Token Usage",["75"],"Format Response",["76"],{"json":"77","pairedItem":"78"},{"json":"79","pairedItem":"80"},{"json":"79","pairedItem":"81"},{"json":"82","pairedItem":"83"},{"json":"84","pairedItem":"85"},{"json":"84","pairedItem":"86"},{"headers":"87","params":"88","query":"89","body":"90","webhookUrl":"91","executionMode":"92"},{"item":0},{"valid":true,"userId":1},{"item":0},{"item":0},{"used_tokens":"93","quota_tokens":"94","tokens_remaining":"95"},{"item":0},{"success":true,"used_tokens":14249,"quota_tokens":50000,"tokens_remaining":35751},{"item":0},{"item":0},{"host":"96","x-real-ip":"97","x-forwarded-for":"97","x-forwarded-proto":"98","connection":"99","sec-ch-ua-platform":"100","authorization":"101","user-agent":"102","accept":"103","sec-ch-ua":"104","dnt":"105","sec-ch-ua-mobile":"106","sec-fetch-site":"107","sec-fetch-mode":"108","sec-fetch-dest":"109","referer":"110","accept-encoding":"111","accept-language":"112","cookie":"113","sec-gpc":"105","if-none-match":"114"},{},{},{},"http://localhost:5678/webhook/wibot/user/tokens","production","14249","50000","35751","localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzAwODYsImV4cCI6MTc2Njg1NjQ4Nn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX19OCF2pwGAF9%2F1pnZFbf%2FU9bjx8bVtFQuoB8uuJ4NZsPcztnq86wTJ%2BQifiUh5ZvOQcOj%2FH3NsgdQ%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX18wdSl%2BbR3A%2BBVvQhbd%2Ft6PfsfHxsKEBaccdHn1PqgznQhdlXcvXpMucO9JmugdZAZPzPIfhheQNJAG2z4HadQI5CAOk4n%2BuIssh%2B059iyHUcXJeKi1D58q%2BCEliIFzvdt2thhgEtEAPvHTYsMEoJxnCpILtIFuLEY%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX1%2B3MJSeV1f7oHZwtV0yoKDLaJhiGtE8gWe2a%2B7YBR5%2BIzzCrIR1ldx3zHzuCpiycKrm8ZvbyAdpk7xyQpiLsCpvxYZYpvUTC17KvTIAGMDiyRCN9uYzTsmLgBICuGc946bvr7TN4sMBy%2BIBbMv55j1q%2F3bhkK1Hg58%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2FERVfhya6DPHED9AM7MdTRO7q4UT3hT67GDfzJYwdaHWTFTkAAuNcmRVwsCWWAnp19SNOZyK4oltRv5k4P7cBM1Nc7%2FlQiwgZDvuNPxkT1S4sc2MkmJXypiMtoEtKtBVezvB1%2BWlofbQ%3D%3D","W/\\"52-49lDe/j8Ze453oj3wcYlm3SsTGE\\""]
79	{"id":"yPYTzGXVRP2JQxs8","name":"WIBOT - Get Conversations","active":true,"activeVersionId":"e1bae720-4a31-4afe-a595-4a35f7e26b0f","isArchived":false,"createdAt":"2025-12-26T17:23:46.197Z","updatedAt":"2025-12-26T17:24:07.735Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/conversations","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"c0f9fbaf-d0bb-4e86-92e9-c3e34e750679","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-656,112],"webhookId":"wibot-conversations"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"a5bd8ac1-82cc-4021-8420-752f46440f49","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"352ea961-e9a7-4651-acad-b594ba9f1c8c","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"9a0fd5d7-2e41-4111-b2b2-f84c1403ea28","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  c.conversation_id::text,\\n  c.title,\\n  TO_CHAR(c.updated_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as updated_at,\\n  COUNT(m.message_id)::integer as message_count\\nFROM conversations c\\nLEFT JOIN messages m ON c.conversation_id = m.conversation_id\\nWHERE c.user_id = {{ $json.userId }}\\nGROUP BY c.conversation_id, c.title, c.updated_at\\nORDER BY c.updated_at DESC\\nLIMIT 50;","options":{}},"id":"8fe150d4-0f4e-41ac-bd90-8978f31f4459","name":"Get Conversations","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[0,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats ou resultats vides\\nif (!rows || rows.length === 0 || !rows[0].json.conversation_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      conversations: []\\n    }\\n  }];\\n}\\n\\nconst conversations = rows.map(row => ({\\n  conversation_id: row.json.conversation_id,\\n  title: row.json.title || 'Nouvelle conversation',\\n  updated_at: row.json.updated_at,\\n  message_count: parseInt(row.json.message_count) || 0\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    conversations\\n  }\\n}];","notice":""},"id":"8d9137c5-9aa8-4938-961f-50bdbc93ee8f","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"463fcf83-1d8e-472a-94df-623b505f1a5d","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[448,0]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Conversations","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Conversations":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Conversations":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766770086644,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766770086644,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766770086644,"executionIndex":1,"source":"29","hints":"30","executionTime":3,"executionStatus":"27","data":"31"},{"startTime":1766770086647,"executionIndex":2,"source":"32","hints":"33","executionTime":0,"executionStatus":"27","data":"34"},{"startTime":1766770086647,"executionIndex":3,"source":"35","hints":"36","executionTime":38,"executionStatus":"27","data":"37"},{"startTime":1766770086685,"executionIndex":4,"source":"38","hints":"39","executionTime":2,"executionStatus":"27","data":"40"},{"startTime":1766770086687,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75","76"],"Get Conversations",["77"],"Format Response",["78"],{"json":"79","pairedItem":"80"},{"json":"81","pairedItem":"82"},{"json":"81","pairedItem":"83"},{"json":"84","pairedItem":"85"},{"json":"86","pairedItem":"85"},{"json":"87","pairedItem":"85"},{"json":"88"},{"json":"88","pairedItem":"89"},{"headers":"90","params":"91","query":"92","body":"93","webhookUrl":"94","executionMode":"95"},{"item":0},{"valid":true,"userId":1},{"item":0},{"item":0},{"conversation_id":"96","title":"97","updated_at":"98","message_count":10},{"item":0},{"conversation_id":"99","title":"100","updated_at":"101","message_count":6},{"conversation_id":"102","title":"103","updated_at":"104","message_count":14},{"success":true,"conversations":"105"},{"item":0},{"host":"106","x-real-ip":"107","x-forwarded-for":"107","x-forwarded-proto":"108","connection":"109","sec-ch-ua-platform":"110","authorization":"111","user-agent":"112","accept":"113","sec-ch-ua":"114","dnt":"115","sec-ch-ua-mobile":"116","sec-fetch-site":"117","sec-fetch-mode":"118","sec-fetch-dest":"119","referer":"120","accept-encoding":"121","accept-language":"122","cookie":"123","sec-gpc":"115"},{},{},{},"http://localhost:5678/webhook/wibot/conversations","production","550e8400-e29b-41d4-a716-446655440000","Conversation de test","2025-12-26T17:16:38Z","963eb9f1-fdcc-4cd5-918b-29fae40c17a0","quel est le chiffre important que je t'ai donné ?","2025-12-26T17:14:33Z","3cc2c8db-afef-4637-accc-31d259f53857","saluty","2025-12-26T16:45:24Z",["124","125","126"],"localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzAwODYsImV4cCI6MTc2Njg1NjQ4Nn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX19OCF2pwGAF9%2F1pnZFbf%2FU9bjx8bVtFQuoB8uuJ4NZsPcztnq86wTJ%2BQifiUh5ZvOQcOj%2FH3NsgdQ%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX18wdSl%2BbR3A%2BBVvQhbd%2Ft6PfsfHxsKEBaccdHn1PqgznQhdlXcvXpMucO9JmugdZAZPzPIfhheQNJAG2z4HadQI5CAOk4n%2BuIssh%2B059iyHUcXJeKi1D58q%2BCEliIFzvdt2thhgEtEAPvHTYsMEoJxnCpILtIFuLEY%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX1%2B3MJSeV1f7oHZwtV0yoKDLaJhiGtE8gWe2a%2B7YBR5%2BIzzCrIR1ldx3zHzuCpiycKrm8ZvbyAdpk7xyQpiLsCpvxYZYpvUTC17KvTIAGMDiyRCN9uYzTsmLgBICuGc946bvr7TN4sMBy%2BIBbMv55j1q%2F3bhkK1Hg58%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2FERVfhya6DPHED9AM7MdTRO7q4UT3hT67GDfzJYwdaHWTFTkAAuNcmRVwsCWWAnp19SNOZyK4oltRv5k4P7cBM1Nc7%2FlQiwgZDvuNPxkT1S4sc2MkmJXypiMtoEtKtBVezvB1%2BWlofbQ%3D%3D",{"conversation_id":"96","title":"97","updated_at":"98","message_count":10},{"conversation_id":"99","title":"100","updated_at":"101","message_count":6},{"conversation_id":"102","title":"103","updated_at":"104","message_count":14}]
81	{"id":"yPYTzGXVRP2JQxs8","name":"WIBOT - Get Conversations","active":true,"activeVersionId":"e1bae720-4a31-4afe-a595-4a35f7e26b0f","isArchived":false,"createdAt":"2025-12-26T17:23:46.197Z","updatedAt":"2025-12-26T17:24:07.735Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/conversations","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"c0f9fbaf-d0bb-4e86-92e9-c3e34e750679","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-656,112],"webhookId":"wibot-conversations"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"a5bd8ac1-82cc-4021-8420-752f46440f49","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"352ea961-e9a7-4651-acad-b594ba9f1c8c","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"9a0fd5d7-2e41-4111-b2b2-f84c1403ea28","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  c.conversation_id::text,\\n  c.title,\\n  TO_CHAR(c.updated_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as updated_at,\\n  COUNT(m.message_id)::integer as message_count\\nFROM conversations c\\nLEFT JOIN messages m ON c.conversation_id = m.conversation_id\\nWHERE c.user_id = {{ $json.userId }}\\nGROUP BY c.conversation_id, c.title, c.updated_at\\nORDER BY c.updated_at DESC\\nLIMIT 50;","options":{}},"id":"8fe150d4-0f4e-41ac-bd90-8978f31f4459","name":"Get Conversations","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[0,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats ou resultats vides\\nif (!rows || rows.length === 0 || !rows[0].json.conversation_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      conversations: []\\n    }\\n  }];\\n}\\n\\nconst conversations = rows.map(row => ({\\n  conversation_id: row.json.conversation_id,\\n  title: row.json.title || 'Nouvelle conversation',\\n  updated_at: row.json.updated_at,\\n  message_count: parseInt(row.json.message_count) || 0\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    conversations\\n  }\\n}];","notice":""},"id":"8d9137c5-9aa8-4938-961f-50bdbc93ee8f","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"463fcf83-1d8e-472a-94df-623b505f1a5d","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[448,0]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Conversations","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Conversations":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Conversations":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766770086707,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766770086707,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766770086707,"executionIndex":1,"source":"29","hints":"30","executionTime":3,"executionStatus":"27","data":"31"},{"startTime":1766770086710,"executionIndex":2,"source":"32","hints":"33","executionTime":1,"executionStatus":"27","data":"34"},{"startTime":1766770086711,"executionIndex":3,"source":"35","hints":"36","executionTime":2,"executionStatus":"27","data":"37"},{"startTime":1766770086713,"executionIndex":4,"source":"38","hints":"39","executionTime":2,"executionStatus":"27","data":"40"},{"startTime":1766770086715,"executionIndex":5,"source":"41","hints":"42","executionTime":0,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75","76"],"Get Conversations",["77"],"Format Response",["78"],{"json":"79","pairedItem":"80"},{"json":"81","pairedItem":"82"},{"json":"81","pairedItem":"83"},{"json":"84","pairedItem":"85"},{"json":"86","pairedItem":"85"},{"json":"87","pairedItem":"85"},{"json":"88"},{"json":"88","pairedItem":"89"},{"headers":"90","params":"91","query":"92","body":"93","webhookUrl":"94","executionMode":"95"},{"item":0},{"valid":true,"userId":1},{"item":0},{"item":0},{"conversation_id":"96","title":"97","updated_at":"98","message_count":10},{"item":0},{"conversation_id":"99","title":"100","updated_at":"101","message_count":6},{"conversation_id":"102","title":"103","updated_at":"104","message_count":14},{"success":true,"conversations":"105"},{"item":0},{"host":"106","x-real-ip":"107","x-forwarded-for":"107","x-forwarded-proto":"108","connection":"109","sec-ch-ua-platform":"110","authorization":"111","user-agent":"112","accept":"113","sec-ch-ua":"114","dnt":"115","sec-ch-ua-mobile":"116","sec-fetch-site":"117","sec-fetch-mode":"118","sec-fetch-dest":"119","referer":"120","accept-encoding":"121","accept-language":"122","cookie":"123","sec-gpc":"115","if-none-match":"124"},{},{},{},"http://localhost:5678/webhook/wibot/conversations","production","550e8400-e29b-41d4-a716-446655440000","Conversation de test","2025-12-26T17:16:38Z","963eb9f1-fdcc-4cd5-918b-29fae40c17a0","quel est le chiffre important que je t'ai donné ?","2025-12-26T17:14:33Z","3cc2c8db-afef-4637-accc-31d259f53857","saluty","2025-12-26T16:45:24Z",["125","126","127"],"localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzAwODYsImV4cCI6MTc2Njg1NjQ4Nn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX19OCF2pwGAF9%2F1pnZFbf%2FU9bjx8bVtFQuoB8uuJ4NZsPcztnq86wTJ%2BQifiUh5ZvOQcOj%2FH3NsgdQ%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX18wdSl%2BbR3A%2BBVvQhbd%2Ft6PfsfHxsKEBaccdHn1PqgznQhdlXcvXpMucO9JmugdZAZPzPIfhheQNJAG2z4HadQI5CAOk4n%2BuIssh%2B059iyHUcXJeKi1D58q%2BCEliIFzvdt2thhgEtEAPvHTYsMEoJxnCpILtIFuLEY%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX1%2B3MJSeV1f7oHZwtV0yoKDLaJhiGtE8gWe2a%2B7YBR5%2BIzzCrIR1ldx3zHzuCpiycKrm8ZvbyAdpk7xyQpiLsCpvxYZYpvUTC17KvTIAGMDiyRCN9uYzTsmLgBICuGc946bvr7TN4sMBy%2BIBbMv55j1q%2F3bhkK1Hg58%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2FERVfhya6DPHED9AM7MdTRO7q4UT3hT67GDfzJYwdaHWTFTkAAuNcmRVwsCWWAnp19SNOZyK4oltRv5k4P7cBM1Nc7%2FlQiwgZDvuNPxkT1S4sc2MkmJXypiMtoEtKtBVezvB1%2BWlofbQ%3D%3D","W/\\"1e4-MqKK+LhPKkKdZuMcKXFAhwJvpyg\\"",{"conversation_id":"96","title":"97","updated_at":"98","message_count":10},{"conversation_id":"99","title":"100","updated_at":"101","message_count":6},{"conversation_id":"102","title":"103","updated_at":"104","message_count":14}]
82	{"id":"NynEDh5rxUQL7788","name":"WIBOT - Chat Main","active":true,"activeVersionId":"7924c06c-c403-4b11-a377-81bbcf664b88","isArchived":false,"createdAt":"2025-12-26T17:23:30.579Z","updatedAt":"2025-12-26T17:24:09.477Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"POST","path":"wibot/chat","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"fa8ec4be-706d-4001-ad6c-fcb0f99736af","name":"Webhook Chat","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-1328,112],"webhookId":"wibot-chat"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst body = $input.first().json.body;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  // Decode base64url payload\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  // Check expiration\\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ \\n    json: { \\n      valid: true, \\n      user: decoded,\\n      userId: decoded.userId,\\n      conversationId: body.conversation_id,\\n      message: body.message,\\n      sessionId: `${decoded.userId}_${body.conversation_id}`\\n    } \\n  }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"0004c18c-eca3-41dc-997e-590e7fd79356","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-1104,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"bfcef1a4-73b6-486c-aab3-5977d98eb079","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-880,112]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"cba8bdb1-b75a-4f70-aa59-b7a0eda05fa5","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[-656,352]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  COALESCE(used_tokens, 0) as used_tokens,\\n  COALESCE(quota_tokens, 50000) as quota_tokens\\nFROM user_token_usage\\nWHERE user_id = {{ $json.userId }}\\n  AND month = DATE_TRUNC('month', CURRENT_DATE)\\nLIMIT 1;","options":{}},"id":"c95bf25e-6737-45ac-a7bb-499bc0b7c7dc","name":"Check Quota","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[-656,112],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\nconst jwtData = $('Verify JWT').first().json;\\n\\nlet usedTokens = 0;\\nlet quotaTokens = 50000;\\n\\nif (rows && rows.length > 0 && rows[0].json.used_tokens !== undefined) {\\n  usedTokens = parseInt(rows[0].json.used_tokens) || 0;\\n  quotaTokens = parseInt(rows[0].json.quota_tokens) || 50000;\\n}\\n\\nconst quotaExceeded = usedTokens >= quotaTokens;\\n\\nreturn [{\\n  json: {\\n    ...jwtData,\\n    usedTokens,\\n    quotaTokens,\\n    quotaExceeded\\n  }\\n}];","notice":""},"id":"4a1c034d-d824-4eec-8f7d-30e703f1deb5","name":"Prepare Quota","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-quota-ok","leftValue":"={{ $json.quotaExceeded }}","rightValue":false,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"19cfec26-6daa-4bf5-a4dd-9c46bc7e775a","name":"Quota OK?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"Quota tokens mensuel depass\\\\u00e9. Limite : 50,000 tokens/mois.\\",\\n  \\"code\\": \\"QUOTA_EXCEEDED\\"\\n}","options":{"responseCode":429,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"664cd109-b947-42ee-b8c1-42b595e37b31","name":"Quota Exceeded","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"aiAgentStarterCallout":"","preBuiltAgentsCallout":"","agent":"toolsAgent","promptType":"define","text":"={{ $json.message }}","hasOutputParser":false,"options":{"systemMessage":"Tu es WIBOT, l'assistant IA interne de WIDIP, une entreprise francaise de services informatiques.\\n\\nTon role:\\n- Aider les employes WIDIP avec leurs questions techniques\\n- Fournir des reponses claires et professionnelles\\n- Utiliser le francais par defaut\\n- Etre concis mais complet\\n\\nStyle:\\n- Utilise le markdown pour formater tes reponses\\n- Mets le code dans des blocs avec le langage specifie\\n- Sois amical mais professionnel"},"credentials":""},"id":"9e04ca0c-5683-4a62-828d-5c057cf62605","name":"AI Agent","type":"@n8n/n8n-nodes-langchain.agent","typeVersion":1.7,"position":[0,0]},{"parameters":{"notice":"","model":"mistral-small-latest","options":{"maxTokens":2048,"temperature":0.7}},"id":"1668e2c3-0095-4fbb-877e-e60722e8d24b","name":"Mistral Cloud Chat Model","type":"@n8n/n8n-nodes-langchain.lmChatMistralCloud","typeVersion":1,"position":[-208,304],"credentials":{"mistralCloudApi":{"id":"b9hl3JA2taufCYVr","name":"Mistral API"}}},{"parameters":{"notice":"","sessionIdType":"customKey","sessionKey":"={{ $('Verify JWT').first().json.sessionId }}","tableName":"n8n_chat_histories","contextWindowLength":10},"id":"cffc5919-5412-4308-9671-843b8d2d035f","name":"Postgres Chat Memory","type":"@n8n/n8n-nodes-langchain.memoryPostgresChat","typeVersion":1.3,"position":[0,304],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const agentResponse = $input.first().json.output;\\nconst jwtData = $('Prepare Quota').first().json;\\n\\n// Estimation tokens (environ 4 chars par token)\\nconst messageTokens = Math.ceil(jwtData.message.length / 4);\\nconst responseTokens = Math.ceil(agentResponse.length / 4);\\nconst tokensUsed = messageTokens + responseTokens;\\n\\nconst newUsedTokens = jwtData.usedTokens + tokensUsed;\\nconst tokensRemaining = jwtData.quotaTokens - newUsedTokens;\\n\\nreturn [{\\n  json: {\\n    userId: jwtData.userId,\\n    conversationId: jwtData.conversationId,\\n    message: jwtData.message,\\n    response: agentResponse,\\n    tokensUsed,\\n    newUsedTokens,\\n    tokensRemaining: Math.max(0, tokensRemaining),\\n    quotaTokens: jwtData.quotaTokens\\n  }\\n}];","notice":""},"id":"b2c9d072-5736-4839-9f3f-8c63b5fe8801","name":"Prepare Save","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"resource":"database","operation":"executeQuery","query":"INSERT INTO conversations (conversation_id, user_id, title, created_at, updated_at)\\nVALUES (\\n  '{{ $json.conversationId }}'::uuid,\\n  {{ $json.userId }},\\n  '{{ $json.message.substring(0, 50).replace(/'/g, \\"''\\") }}',\\n  NOW(),\\n  NOW()\\n)\\nON CONFLICT (conversation_id)\\nDO UPDATE SET updated_at = NOW();","options":{}},"id":"6c1ace5b-ec88-44b5-a9b5-182a4957e5c9","name":"UPSERT Conversation","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[448,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"resource":"database","operation":"executeQuery","query":"INSERT INTO messages (conversation_id, user_id, role, content, tokens, created_at)\\nVALUES (\\n  '{{ $('Prepare Save').first().json.conversationId }}'::uuid,\\n  {{ $('Prepare Save').first().json.userId }},\\n  'user',\\n  '{{ $('Prepare Save').first().json.message.replace(/'/g, \\"''\\").replace(/\\\\\\\\/g, '\\\\\\\\\\\\\\\\') }}',\\n  {{ Math.ceil($('Prepare Save').first().json.message.length / 4) }},\\n  NOW()\\n);","options":{}},"id":"19bf528f-0b9d-44d5-b768-58e63ddee026","name":"INSERT User Message","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[672,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"resource":"database","operation":"executeQuery","query":"INSERT INTO messages (conversation_id, user_id, role, content, tokens, created_at)\\nVALUES (\\n  '{{ $('Prepare Save').first().json.conversationId }}'::uuid,\\n  {{ $('Prepare Save').first().json.userId }},\\n  'assistant',\\n  '{{ $('Prepare Save').first().json.response.replace(/'/g, \\"''\\").replace(/\\\\\\\\/g, '\\\\\\\\\\\\\\\\') }}',\\n  {{ Math.ceil($('Prepare Save').first().json.response.length / 4) }},\\n  NOW()\\n);","options":{}},"id":"22a33991-a55c-428d-b673-3b0eef3b8a1a","name":"INSERT Assistant Message","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[880,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"resource":"database","operation":"executeQuery","query":"INSERT INTO user_token_usage (user_id, month, used_tokens, quota_tokens)\\nVALUES (\\n  {{ $('Prepare Save').first().json.userId }},\\n  DATE_TRUNC('month', CURRENT_DATE),\\n  {{ $('Prepare Save').first().json.tokensUsed }},\\n  50000\\n)\\nON CONFLICT (user_id, month)\\nDO UPDATE SET used_tokens = user_token_usage.used_tokens + {{ $('Prepare Save').first().json.tokensUsed }};","options":{}},"id":"344a1edc-fdf7-4ba0-a506-10b00624a0ac","name":"UPDATE Token Usage","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[1104,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const data = $('Prepare Save').first().json;\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    response: data.response,\\n    tokens_used: data.tokensUsed,\\n    tokens_remaining: data.tokensRemaining,\\n    conversation_id: data.conversationId\\n  }\\n}];","notice":""},"id":"d3257586-4db1-4ccf-8b88-2ec7203c06ee","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1328,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"bfca5f39-23d9-494d-9b4e-767225255749","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1552,0]}],"connections":{"Webhook Chat":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Check Quota","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Check Quota":{"main":[[{"node":"Prepare Quota","type":"main","index":0}]]},"Prepare Quota":{"main":[[{"node":"Quota OK?","type":"main","index":0}]]},"Quota OK?":{"main":[[{"node":"AI Agent","type":"main","index":0}],[{"node":"Quota Exceeded","type":"main","index":0}]]},"Mistral Cloud Chat Model":{"ai_languageModel":[[{"node":"AI Agent","type":"ai_languageModel","index":0}]]},"Postgres Chat Memory":{"ai_memory":[[{"node":"AI Agent","type":"ai_memory","index":0}]]},"AI Agent":{"main":[[{"node":"Prepare Save","type":"main","index":0}]]},"Prepare Save":{"main":[[{"node":"UPSERT Conversation","type":"main","index":0}]]},"UPSERT Conversation":{"main":[[{"node":"INSERT User Message","type":"main","index":0}]]},"INSERT User Message":{"main":[[{"node":"INSERT Assistant Message","type":"main","index":0}]]},"INSERT Assistant Message":{"main":[[{"node":"UPDATE Token Usage","type":"main","index":0}]]},"UPDATE Token Usage":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook Chat":"12","Verify JWT":"13","JWT Valid?":"14","Check Quota":"15","Prepare Quota":"16","Quota OK?":"17","Postgres Chat Memory":"18","Mistral Cloud Chat Model":"19","AI Agent":"20","Prepare Save":"21","UPSERT Conversation":"22","INSERT User Message":"23","INSERT Assistant Message":"24","UPDATE Token Usage":"25","Format Response":"26","Success":"27"},"Success",{},[],{"Postgres Chat Memory":"28","Mistral Cloud Chat Model":"29"},{},{},{"version":1,"establishedAt":1766770093182,"source":"30"},["31"],["32"],["33"],["34"],["35"],["36"],["37","38"],["39"],["40"],["41"],["42"],["43"],["44"],["45"],["46"],["47"],["48","49"],["50"],"webhook",{"startTime":1766770093182,"executionIndex":0,"source":"51","hints":"52","executionTime":1,"executionStatus":"53","data":"54"},{"startTime":1766770093183,"executionIndex":1,"source":"55","hints":"56","executionTime":2,"executionStatus":"53","data":"57"},{"startTime":1766770093185,"executionIndex":2,"source":"58","hints":"59","executionTime":1,"executionStatus":"53","data":"60"},{"startTime":1766770093186,"executionIndex":3,"source":"61","hints":"62","executionTime":1,"executionStatus":"53","data":"63"},{"startTime":1766770093188,"executionIndex":4,"source":"64","hints":"65","executionTime":1,"executionStatus":"53","data":"66"},{"startTime":1766770093190,"executionIndex":5,"source":"67","hints":"68","executionTime":0,"executionStatus":"53","data":"69"},{"startTime":1766770093193,"executionTime":6,"executionIndex":7,"executionStatus":"53","source":"70","data":"71","inputOverride":"72","metadata":"73"},{"startTime":1766770093507,"executionTime":4,"executionIndex":9,"executionStatus":"53","source":"74","data":"75","inputOverride":"76","metadata":"77"},{"startTime":1766770093209,"executionTime":297,"executionIndex":8,"executionStatus":"53","source":"78","data":"79","inputOverride":"80","metadata":"81"},{"startTime":1766770093190,"executionIndex":6,"source":"82","hints":"83","executionTime":321,"executionStatus":"53","data":"84"},{"startTime":1766770093512,"executionIndex":10,"source":"85","hints":"86","executionTime":2,"executionStatus":"53","data":"87"},{"startTime":1766770093514,"executionIndex":11,"source":"88","hints":"89","executionTime":4,"executionStatus":"53","data":"90"},{"startTime":1766770093518,"executionIndex":12,"source":"91","hints":"92","executionTime":3,"executionStatus":"53","data":"93"},{"startTime":1766770093522,"executionIndex":13,"source":"94","hints":"95","executionTime":2,"executionStatus":"53","data":"96"},{"startTime":1766770093525,"executionIndex":14,"source":"97","hints":"98","executionTime":3,"executionStatus":"53","data":"99"},{"startTime":1766770093528,"executionIndex":15,"source":"100","hints":"101","executionTime":2,"executionStatus":"53","data":"102"},{"startTime":1766770093530,"executionIndex":16,"source":"103","hints":"104","executionTime":1,"executionStatus":"53","data":"105"},{"subRun":"106"},{"subRun":"107"},{"subRun":"108"},[],[],"success",{"main":"109"},["110"],["111"],{"main":"112"},["113"],[],{"main":"114"},["115"],[],{"main":"116"},["117"],["118"],{"main":"119"},["120"],[],{"main":"121"},["122"],{"ai_memory":"123"},{"ai_memory":"124"},{"subRun":"106"},["125"],{"ai_memory":"126"},{"ai_memory":"127"},{"subRun":"107"},["128"],{"ai_languageModel":"129"},{"ai_languageModel":"130"},{"subRun":"108"},["131"],[],{"main":"132"},["133"],["134"],{"main":"135"},["136"],[],{"main":"137"},["138"],[],{"main":"139"},["140"],[],{"main":"141"},["142"],[],{"main":"143"},["144"],["145"],{"main":"146"},["147"],[],{"main":"148"},["149"],["150"],["151"],["152"],{"previousNode":"153"},{"message":"154","location":"155"},["156"],{"previousNode":"157"},["158","159"],{"previousNode":"160"},["161"],{"previousNode":"162"},{"message":"154","location":"155"},["163"],{"previousNode":"164"},["165","166"],{"previousNode":"167","previousNodeRun":0},["168"],["169"],{"previousNode":"167","previousNodeRun":0},["170"],["171"],{"previousNode":"167","previousNodeRun":0},["172"],["173"],{"previousNode":"174"},["175"],{"previousNode":"167"},{"message":"154","location":"155"},["176"],{"previousNode":"177"},["178"],{"previousNode":"179"},["180"],{"previousNode":"181"},["182"],{"previousNode":"183"},["184"],{"previousNode":"185"},{"message":"154","location":"155"},["186"],{"previousNode":"187"},["188"],{"node":"189","runIndex":0},{"node":"189","runIndex":1},{"node":"190","runIndex":0},["191"],"Webhook Chat","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["192"],"Verify JWT",["193"],[],"JWT Valid?",["194"],"Check Quota",["195"],"Prepare Quota",["196"],[],"AI Agent",["197"],["198"],["199"],["200"],["201"],["202"],"Quota OK?",["203"],["204"],"Prepare Save",["205"],"UPSERT Conversation",["206"],"INSERT User Message",["207"],"INSERT Assistant Message",["208"],"UPDATE Token Usage",["209"],"Format Response",["210"],"Postgres Chat Memory","Mistral Cloud Chat Model",{"json":"211","pairedItem":"212"},{"json":"213","pairedItem":"214"},{"json":"213","pairedItem":"215"},{"json":"216","pairedItem":"217"},{"json":"218","pairedItem":"219"},{"json":"218","pairedItem":"220"},{"json":"221"},{"json":"222"},{"json":"223"},{"json":"224"},{"json":"225"},{"json":"226"},{"json":"227","pairedItem":"228"},{"json":"229","pairedItem":"230"},{"json":"231","pairedItem":"232"},{"json":"233","pairedItem":"234"},{"json":"235","pairedItem":"236"},{"json":"237","pairedItem":"238"},{"json":"239","pairedItem":"240"},{"json":"239","pairedItem":"241"},{"headers":"242","params":"243","query":"244","body":"245","webhookUrl":"246","executionMode":"247"},{"item":0},{"valid":true,"user":"248","userId":1,"conversationId":"249","message":"250","sessionId":"251"},{"item":0},{"item":0},{"used_tokens":"252","quota_tokens":"253"},{"item":0},{"valid":true,"user":"254","userId":1,"conversationId":"249","message":"250","sessionId":"251","usedTokens":14249,"quotaTokens":50000,"quotaExceeded":false},{"item":0},{"item":0},{"action":"255","chatHistory":"256"},{"action":"255","values":"257"},{"action":"258","chatHistory":"259"},{"action":"258","input":"260","output":"261"},{"response":"262","tokenUsage":"263"},{"messages":"264","estimatedTokens":176,"options":"265"},{"output":"266"},{"item":0},{"userId":1,"conversationId":"249","message":"250","response":"266","tokensUsed":14,"newUsedTokens":14263,"tokensRemaining":35737,"quotaTokens":50000},{"item":0},{"success":true},["267"],{"success":true},["268"],{"success":true},["269"],{"success":true},["270"],{"success":true,"response":"266","tokens_used":14,"tokens_remaining":35737,"conversation_id":"249"},{"item":0},{"item":0},{"host":"271","x-real-ip":"272","x-forwarded-for":"272","x-forwarded-proto":"273","connection":"274","content-length":"275","sec-ch-ua-platform":"276","authorization":"277","sec-ch-ua":"278","sec-ch-ua-mobile":"279","user-agent":"280","accept":"281","dnt":"282","content-type":"283","origin":"284","sec-fetch-site":"285","sec-fetch-mode":"286","sec-fetch-dest":"287","referer":"288","accept-encoding":"289","accept-language":"290","cookie":"291","sec-gpc":"282"},{},{},{"conversation_id":"249","message":"250"},"http://localhost:5678/webhook/wibot/chat","production",{"userId":1,"username":"292","role":"293","iat":1766770086,"exp":1766856486},"550e8400-e29b-41d4-a716-446655440000","hey","1_550e8400-e29b-41d4-a716-446655440000","14249","50000",{"userId":1,"username":"292","role":"293","iat":1766770086,"exp":1766856486},"loadMemoryVariables",["294","295","296","297"],{"input":"250","system_message":"298","formatting_instructions":"299"},"saveContext",["300","301","302","303","304","305"],{"input":"250","system_message":"298","formatting_instructions":"299"},{"input":"250","system_message":"298","formatting_instructions":"299","chat_history":"256","output":"266"},{"generations":"306"},{"completionTokens":12,"promptTokens":179,"totalTokens":191},["307"],{"mistral_api_key":"308","model":"309","max_tokens":2048,"temperature":0.7,"metadata":"310"},"Bonjour ! Comment puis-je vous aider aujourd'hui ?",{"item":0},{"item":0},{"item":0},{"item":0},"localhost","172.20.0.1","http","close","74","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzAwODYsImV4cCI6MTc2Njg1NjQ4Nn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","?0","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","1","application/json","http://localhost:5173","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX19OCF2pwGAF9%2F1pnZFbf%2FU9bjx8bVtFQuoB8uuJ4NZsPcztnq86wTJ%2BQifiUh5ZvOQcOj%2FH3NsgdQ%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX18wdSl%2BbR3A%2BBVvQhbd%2Ft6PfsfHxsKEBaccdHn1PqgznQhdlXcvXpMucO9JmugdZAZPzPIfhheQNJAG2z4HadQI5CAOk4n%2BuIssh%2B059iyHUcXJeKi1D58q%2BCEliIFzvdt2thhgEtEAPvHTYsMEoJxnCpILtIFuLEY%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX1%2B3MJSeV1f7oHZwtV0yoKDLaJhiGtE8gWe2a%2B7YBR5%2BIzzCrIR1ldx3zHzuCpiycKrm8ZvbyAdpk7xyQpiLsCpvxYZYpvUTC17KvTIAGMDiyRCN9uYzTsmLgBICuGc946bvr7TN4sMBy%2BIBbMv55j1q%2F3bhkK1Hg58%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2FERVfhya6DPHED9AM7MdTRO7q4UT3hT67GDfzJYwdaHWTFTkAAuNcmRVwsCWWAnp19SNOZyK4oltRv5k4P7cBM1Nc7%2FlQiwgZDvuNPxkT1S4sc2MkmJXypiMtoEtKtBVezvB1%2BWlofbQ%3D%3D","khora","admin",{"lc":1,"type":"311","id":"312","kwargs":"313"},{"lc":1,"type":"311","id":"314","kwargs":"315"},{"lc":1,"type":"311","id":"316","kwargs":"317"},{"lc":1,"type":"311","id":"318","kwargs":"319"},"Tu es WIBOT, l'assistant IA interne de WIDIP, une entreprise francaise de services informatiques.\\n\\nTon role:\\n- Aider les employes WIDIP avec leurs questions techniques\\n- Fournir des reponses claires et professionnelles\\n- Utiliser le francais par defaut\\n- Etre concis mais complet\\n\\nStyle:\\n- Utilise le markdown pour formater tes reponses\\n- Mets le code dans des blocs avec le langage specifie\\n- Sois amical mais professionnel","IMPORTANT: For your response to user, you MUST use the `format_final_json_response` tool with your complete answer formatted according to the required schema. Do not attempt to format the JSON manually - always use this tool. Your response will be rejected if it is not properly formatted through this tool. Only use this tool once you are ready to provide your final answer.",{"lc":1,"type":"311","id":"320","kwargs":"321"},{"lc":1,"type":"311","id":"322","kwargs":"323"},{"lc":1,"type":"311","id":"324","kwargs":"325"},{"lc":1,"type":"311","id":"326","kwargs":"327"},{"lc":1,"type":"311","id":"328","kwargs":"329"},{"lc":1,"type":"311","id":"330","kwargs":"331"},["332"],"System: Tu es WIBOT, l'assistant IA interne de WIDIP, une entreprise francaise de services informatiques.\\n\\nTon role:\\n- Aider les employes WIDIP avec leurs questions techniques\\n- Fournir des reponses claires et professionnelles\\n- Utiliser le francais par defaut\\n- Etre concis mais complet\\n\\nStyle:\\n- Utilise le markdown pour formater tes reponses\\n- Mets le code dans des blocs avec le langage specifie\\n- Sois amical mais professionnel\\nHuman: salut\\nAI: Salut ! Comment puis-je vous aider aujourd'hui ?\\nHuman: ddadzax\\nAI: Bonjour ! Je ne suis pas sûr de comprendre votre demande. Pourriez-vous préciser ou reformuler votre question ? Je suis là pour vous aider avec les questions techniques ou toute autre demande liée à WIDIP.\\nHuman: hey",{"lc":1,"type":"333","id":"334"},"mistral-small-latest",{},"constructor",["335","336","337"],{"content":"338","additional_kwargs":"339","response_metadata":"340"},["335","336","341"],{"content":"342","tool_calls":"343","additional_kwargs":"344","response_metadata":"345","invalid_tool_calls":"346"},["335","336","337"],{"content":"347","additional_kwargs":"348","response_metadata":"349"},["335","336","341"],{"content":"350","tool_calls":"351","additional_kwargs":"352","response_metadata":"353","invalid_tool_calls":"354"},["335","336","337"],{"content":"338","additional_kwargs":"355","response_metadata":"356"},["335","336","341"],{"content":"342","tool_calls":"357","additional_kwargs":"358","response_metadata":"359","invalid_tool_calls":"360"},["335","336","337"],{"content":"347","additional_kwargs":"361","response_metadata":"362"},["335","336","341"],{"content":"350","tool_calls":"363","additional_kwargs":"364","response_metadata":"365","invalid_tool_calls":"366"},["335","336","337"],{"content":"250","additional_kwargs":"367","response_metadata":"368"},["335","336","341"],{"content":"266","tool_calls":"369","additional_kwargs":"370","response_metadata":"371","invalid_tool_calls":"372"},["373"],"secret",["374"],"langchain_core","messages","HumanMessage","salut",{},{},"AIMessage","Salut ! Comment puis-je vous aider aujourd'hui ?",[],{},{},[],"ddadzax",{},{},"Bonjour ! Je ne suis pas sûr de comprendre votre demande. Pourriez-vous préciser ou reformuler votre question ? Je suis là pour vous aider avec les questions techniques ou toute autre demande liée à WIDIP.",[],{},{},[],{},{},[],{},{},[],{},{},[],{},{},[],{},{},[],{},{},[],{"text":"266","generationInfo":"375"},"MISTRAL_API_KEY",{"prompt":0,"completion":0}]
83	{"id":"yPYTzGXVRP2JQxs8","name":"WIBOT - Get Conversations","active":true,"activeVersionId":"e1bae720-4a31-4afe-a595-4a35f7e26b0f","isArchived":false,"createdAt":"2025-12-26T17:23:46.197Z","updatedAt":"2025-12-26T17:24:07.735Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/conversations","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"c0f9fbaf-d0bb-4e86-92e9-c3e34e750679","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-656,112],"webhookId":"wibot-conversations"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"a5bd8ac1-82cc-4021-8420-752f46440f49","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"352ea961-e9a7-4651-acad-b594ba9f1c8c","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"9a0fd5d7-2e41-4111-b2b2-f84c1403ea28","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  c.conversation_id::text,\\n  c.title,\\n  TO_CHAR(c.updated_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as updated_at,\\n  COUNT(m.message_id)::integer as message_count\\nFROM conversations c\\nLEFT JOIN messages m ON c.conversation_id = m.conversation_id\\nWHERE c.user_id = {{ $json.userId }}\\nGROUP BY c.conversation_id, c.title, c.updated_at\\nORDER BY c.updated_at DESC\\nLIMIT 50;","options":{}},"id":"8fe150d4-0f4e-41ac-bd90-8978f31f4459","name":"Get Conversations","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[0,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats ou resultats vides\\nif (!rows || rows.length === 0 || !rows[0].json.conversation_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      conversations: []\\n    }\\n  }];\\n}\\n\\nconst conversations = rows.map(row => ({\\n  conversation_id: row.json.conversation_id,\\n  title: row.json.title || 'Nouvelle conversation',\\n  updated_at: row.json.updated_at,\\n  message_count: parseInt(row.json.message_count) || 0\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    conversations\\n  }\\n}];","notice":""},"id":"8d9137c5-9aa8-4938-961f-50bdbc93ee8f","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"463fcf83-1d8e-472a-94df-623b505f1a5d","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[448,0]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Conversations","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Conversations":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Conversations":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766770198306,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766770198306,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766770198306,"executionIndex":1,"source":"29","hints":"30","executionTime":3,"executionStatus":"27","data":"31"},{"startTime":1766770198309,"executionIndex":2,"source":"32","hints":"33","executionTime":0,"executionStatus":"27","data":"34"},{"startTime":1766770198309,"executionIndex":3,"source":"35","hints":"36","executionTime":8,"executionStatus":"27","data":"37"},{"startTime":1766770198317,"executionIndex":4,"source":"38","hints":"39","executionTime":3,"executionStatus":"27","data":"40"},{"startTime":1766770198320,"executionIndex":5,"source":"41","hints":"42","executionTime":0,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75","76"],"Get Conversations",["77"],"Format Response",["78"],{"json":"79","pairedItem":"80"},{"json":"81","pairedItem":"82"},{"json":"81","pairedItem":"83"},{"json":"84","pairedItem":"85"},{"json":"86","pairedItem":"85"},{"json":"87","pairedItem":"85"},{"json":"88"},{"json":"88","pairedItem":"89"},{"headers":"90","params":"91","query":"92","body":"93","webhookUrl":"94","executionMode":"95"},{"item":0},{"valid":true,"userId":1},{"item":0},{"item":0},{"conversation_id":"96","title":"97","updated_at":"98","message_count":12},{"item":0},{"conversation_id":"99","title":"100","updated_at":"101","message_count":6},{"conversation_id":"102","title":"103","updated_at":"104","message_count":14},{"success":true,"conversations":"105"},{"item":0},{"host":"106","x-real-ip":"107","x-forwarded-for":"107","x-forwarded-proto":"108","connection":"109","user-agent":"110","accept":"111","authorization":"112","content-type":"113"},{},{},{},"http://localhost:5678/webhook/wibot/conversations","production","550e8400-e29b-41d4-a716-446655440000","Conversation de test","2025-12-26T17:28:13Z","963eb9f1-fdcc-4cd5-918b-29fae40c17a0","quel est le chiffre important que je t'ai donné ?","2025-12-26T17:14:33Z","3cc2c8db-afef-4637-accc-31d259f53857","saluty","2025-12-26T16:45:24Z",["114","115","116"],"localhost","172.20.0.1","http","close","curl/8.12.1","*/*","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3Njk5NTgsImV4cCI6MTc2Njg1NjM1OH0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","application/json",{"conversation_id":"96","title":"97","updated_at":"98","message_count":12},{"conversation_id":"99","title":"100","updated_at":"101","message_count":6},{"conversation_id":"102","title":"103","updated_at":"104","message_count":14}]
84	{"id":"c8fbjjX9ObuzBE4b","name":"WIBOT - Get User Tokens","active":true,"activeVersionId":"62643582-5e10-4f85-9c6c-74a85d102e67","isArchived":false,"createdAt":"2025-12-26T17:24:01.471Z","updatedAt":"2025-12-26T17:24:05.529Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/user/tokens","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"8fcee23f-b3e4-4c28-ad04-4ba456f7752a","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-656,112],"webhookId":"wibot-user-tokens"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"d8de2cd5-94e4-49a5-a318-1ee1c389abd9","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"c9c309e4-53ba-46be-8960-13da82f4f5f7","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"83cd3ac8-fb46-4de5-a8ce-5d24be08334c","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  COALESCE(used_tokens, 0) as used_tokens,\\n  COALESCE(quota_tokens, 50000) as quota_tokens,\\n  COALESCE(quota_tokens, 50000) - COALESCE(used_tokens, 0) as tokens_remaining\\nFROM user_token_usage\\nWHERE user_id = {{ $json.userId }}\\n  AND month = DATE_TRUNC('month', CURRENT_DATE)\\nLIMIT 1;","options":{}},"id":"b35fa964-24c4-49ed-a3b6-7df917662ceb","name":"Get Token Usage","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[0,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\nconst jwtData = $('Verify JWT').first().json;\\n\\n// Si pas de donnees, l'utilisateur n'a pas encore utilise de tokens ce mois\\nif (!rows || rows.length === 0 || rows[0].json.tokens_remaining === undefined) {\\n  return [{\\n    json: {\\n      success: true,\\n      used_tokens: 0,\\n      quota_tokens: 50000,\\n      tokens_remaining: 50000\\n    }\\n  }];\\n}\\n\\nconst data = rows[0].json;\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    used_tokens: parseInt(data.used_tokens) || 0,\\n    quota_tokens: parseInt(data.quota_tokens) || 50000,\\n    tokens_remaining: parseInt(data.tokens_remaining) || 50000\\n  }\\n}];","notice":""},"id":"7d9b1764-6fed-49d3-957f-402aa7f05696","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"67daad4e-a2fe-4b36-b18c-065181b80de3","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[448,0]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Token Usage","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Token Usage":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Token Usage":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766770214384,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766770214384,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766770214384,"executionIndex":1,"source":"29","hints":"30","executionTime":2,"executionStatus":"27","data":"31"},{"startTime":1766770214386,"executionIndex":2,"source":"32","hints":"33","executionTime":1,"executionStatus":"27","data":"34"},{"startTime":1766770214387,"executionIndex":3,"source":"35","hints":"36","executionTime":6,"executionStatus":"27","data":"37"},{"startTime":1766770214393,"executionIndex":4,"source":"38","hints":"39","executionTime":2,"executionStatus":"27","data":"40"},{"startTime":1766770214395,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74"],"Get Token Usage",["75"],"Format Response",["76"],{"json":"77","pairedItem":"78"},{"json":"79","pairedItem":"80"},{"json":"79","pairedItem":"81"},{"json":"82","pairedItem":"83"},{"json":"84","pairedItem":"85"},{"json":"84","pairedItem":"86"},{"headers":"87","params":"88","query":"89","body":"90","webhookUrl":"91","executionMode":"92"},{"item":0},{"valid":true,"userId":1},{"item":0},{"item":0},{"used_tokens":"93","quota_tokens":"94","tokens_remaining":"95"},{"item":0},{"success":true,"used_tokens":14263,"quota_tokens":50000,"tokens_remaining":35737},{"item":0},{"item":0},{"host":"96","x-real-ip":"97","x-forwarded-for":"97","x-forwarded-proto":"98","connection":"99","user-agent":"100","accept":"101","authorization":"102","content-type":"103"},{},{},{},"http://localhost:5678/webhook/wibot/user/tokens","production","14263","50000","35737","localhost","172.20.0.1","http","close","curl/8.12.1","*/*","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3Njk5NTgsImV4cCI6MTc2Njg1NjM1OH0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","application/json"]
85	{"id":"NynEDh5rxUQL7788","name":"WIBOT - Chat Main","active":true,"activeVersionId":"7924c06c-c403-4b11-a377-81bbcf664b88","isArchived":false,"createdAt":"2025-12-26T17:23:30.579Z","updatedAt":"2025-12-26T17:24:09.477Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"POST","path":"wibot/chat","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"fa8ec4be-706d-4001-ad6c-fcb0f99736af","name":"Webhook Chat","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-1328,112],"webhookId":"wibot-chat"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst body = $input.first().json.body;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  // Decode base64url payload\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  // Check expiration\\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ \\n    json: { \\n      valid: true, \\n      user: decoded,\\n      userId: decoded.userId,\\n      conversationId: body.conversation_id,\\n      message: body.message,\\n      sessionId: `${decoded.userId}_${body.conversation_id}`\\n    } \\n  }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"0004c18c-eca3-41dc-997e-590e7fd79356","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-1104,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"bfcef1a4-73b6-486c-aab3-5977d98eb079","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-880,112]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"cba8bdb1-b75a-4f70-aa59-b7a0eda05fa5","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[-656,352]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  COALESCE(used_tokens, 0) as used_tokens,\\n  COALESCE(quota_tokens, 50000) as quota_tokens\\nFROM user_token_usage\\nWHERE user_id = {{ $json.userId }}\\n  AND month = DATE_TRUNC('month', CURRENT_DATE)\\nLIMIT 1;","options":{}},"id":"c95bf25e-6737-45ac-a7bb-499bc0b7c7dc","name":"Check Quota","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[-656,112],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\nconst jwtData = $('Verify JWT').first().json;\\n\\nlet usedTokens = 0;\\nlet quotaTokens = 50000;\\n\\nif (rows && rows.length > 0 && rows[0].json.used_tokens !== undefined) {\\n  usedTokens = parseInt(rows[0].json.used_tokens) || 0;\\n  quotaTokens = parseInt(rows[0].json.quota_tokens) || 50000;\\n}\\n\\nconst quotaExceeded = usedTokens >= quotaTokens;\\n\\nreturn [{\\n  json: {\\n    ...jwtData,\\n    usedTokens,\\n    quotaTokens,\\n    quotaExceeded\\n  }\\n}];","notice":""},"id":"4a1c034d-d824-4eec-8f7d-30e703f1deb5","name":"Prepare Quota","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-quota-ok","leftValue":"={{ $json.quotaExceeded }}","rightValue":false,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"19cfec26-6daa-4bf5-a4dd-9c46bc7e775a","name":"Quota OK?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"Quota tokens mensuel depass\\\\u00e9. Limite : 50,000 tokens/mois.\\",\\n  \\"code\\": \\"QUOTA_EXCEEDED\\"\\n}","options":{"responseCode":429,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"664cd109-b947-42ee-b8c1-42b595e37b31","name":"Quota Exceeded","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"aiAgentStarterCallout":"","preBuiltAgentsCallout":"","agent":"toolsAgent","promptType":"define","text":"={{ $json.message }}","hasOutputParser":false,"options":{"systemMessage":"Tu es WIBOT, l'assistant IA interne de WIDIP, une entreprise francaise de services informatiques.\\n\\nTon role:\\n- Aider les employes WIDIP avec leurs questions techniques\\n- Fournir des reponses claires et professionnelles\\n- Utiliser le francais par defaut\\n- Etre concis mais complet\\n\\nStyle:\\n- Utilise le markdown pour formater tes reponses\\n- Mets le code dans des blocs avec le langage specifie\\n- Sois amical mais professionnel"},"credentials":""},"id":"9e04ca0c-5683-4a62-828d-5c057cf62605","name":"AI Agent","type":"@n8n/n8n-nodes-langchain.agent","typeVersion":1.7,"position":[0,0]},{"parameters":{"notice":"","model":"mistral-small-latest","options":{"maxTokens":2048,"temperature":0.7}},"id":"1668e2c3-0095-4fbb-877e-e60722e8d24b","name":"Mistral Cloud Chat Model","type":"@n8n/n8n-nodes-langchain.lmChatMistralCloud","typeVersion":1,"position":[-208,304],"credentials":{"mistralCloudApi":{"id":"b9hl3JA2taufCYVr","name":"Mistral API"}}},{"parameters":{"notice":"","sessionIdType":"customKey","sessionKey":"={{ $('Verify JWT').first().json.sessionId }}","tableName":"n8n_chat_histories","contextWindowLength":10},"id":"cffc5919-5412-4308-9671-843b8d2d035f","name":"Postgres Chat Memory","type":"@n8n/n8n-nodes-langchain.memoryPostgresChat","typeVersion":1.3,"position":[0,304],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const agentResponse = $input.first().json.output;\\nconst jwtData = $('Prepare Quota').first().json;\\n\\n// Estimation tokens (environ 4 chars par token)\\nconst messageTokens = Math.ceil(jwtData.message.length / 4);\\nconst responseTokens = Math.ceil(agentResponse.length / 4);\\nconst tokensUsed = messageTokens + responseTokens;\\n\\nconst newUsedTokens = jwtData.usedTokens + tokensUsed;\\nconst tokensRemaining = jwtData.quotaTokens - newUsedTokens;\\n\\nreturn [{\\n  json: {\\n    userId: jwtData.userId,\\n    conversationId: jwtData.conversationId,\\n    message: jwtData.message,\\n    response: agentResponse,\\n    tokensUsed,\\n    newUsedTokens,\\n    tokensRemaining: Math.max(0, tokensRemaining),\\n    quotaTokens: jwtData.quotaTokens\\n  }\\n}];","notice":""},"id":"b2c9d072-5736-4839-9f3f-8c63b5fe8801","name":"Prepare Save","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"resource":"database","operation":"executeQuery","query":"INSERT INTO conversations (conversation_id, user_id, title, created_at, updated_at)\\nVALUES (\\n  '{{ $json.conversationId }}'::uuid,\\n  {{ $json.userId }},\\n  '{{ $json.message.substring(0, 50).replace(/'/g, \\"''\\") }}',\\n  NOW(),\\n  NOW()\\n)\\nON CONFLICT (conversation_id)\\nDO UPDATE SET updated_at = NOW();","options":{}},"id":"6c1ace5b-ec88-44b5-a9b5-182a4957e5c9","name":"UPSERT Conversation","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[448,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"resource":"database","operation":"executeQuery","query":"INSERT INTO messages (conversation_id, user_id, role, content, tokens, created_at)\\nVALUES (\\n  '{{ $('Prepare Save').first().json.conversationId }}'::uuid,\\n  {{ $('Prepare Save').first().json.userId }},\\n  'user',\\n  '{{ $('Prepare Save').first().json.message.replace(/'/g, \\"''\\").replace(/\\\\\\\\/g, '\\\\\\\\\\\\\\\\') }}',\\n  {{ Math.ceil($('Prepare Save').first().json.message.length / 4) }},\\n  NOW()\\n);","options":{}},"id":"19bf528f-0b9d-44d5-b768-58e63ddee026","name":"INSERT User Message","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[672,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"resource":"database","operation":"executeQuery","query":"INSERT INTO messages (conversation_id, user_id, role, content, tokens, created_at)\\nVALUES (\\n  '{{ $('Prepare Save').first().json.conversationId }}'::uuid,\\n  {{ $('Prepare Save').first().json.userId }},\\n  'assistant',\\n  '{{ $('Prepare Save').first().json.response.replace(/'/g, \\"''\\").replace(/\\\\\\\\/g, '\\\\\\\\\\\\\\\\') }}',\\n  {{ Math.ceil($('Prepare Save').first().json.response.length / 4) }},\\n  NOW()\\n);","options":{}},"id":"22a33991-a55c-428d-b673-3b0eef3b8a1a","name":"INSERT Assistant Message","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[880,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"resource":"database","operation":"executeQuery","query":"INSERT INTO user_token_usage (user_id, month, used_tokens, quota_tokens)\\nVALUES (\\n  {{ $('Prepare Save').first().json.userId }},\\n  DATE_TRUNC('month', CURRENT_DATE),\\n  {{ $('Prepare Save').first().json.tokensUsed }},\\n  50000\\n)\\nON CONFLICT (user_id, month)\\nDO UPDATE SET used_tokens = user_token_usage.used_tokens + {{ $('Prepare Save').first().json.tokensUsed }};","options":{}},"id":"344a1edc-fdf7-4ba0-a506-10b00624a0ac","name":"UPDATE Token Usage","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[1104,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const data = $('Prepare Save').first().json;\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    response: data.response,\\n    tokens_used: data.tokensUsed,\\n    tokens_remaining: data.tokensRemaining,\\n    conversation_id: data.conversationId\\n  }\\n}];","notice":""},"id":"d3257586-4db1-4ccf-8b88-2ec7203c06ee","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1328,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"bfca5f39-23d9-494d-9b4e-767225255749","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1552,0]}],"connections":{"Webhook Chat":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Check Quota","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Check Quota":{"main":[[{"node":"Prepare Quota","type":"main","index":0}]]},"Prepare Quota":{"main":[[{"node":"Quota OK?","type":"main","index":0}]]},"Quota OK?":{"main":[[{"node":"AI Agent","type":"main","index":0}],[{"node":"Quota Exceeded","type":"main","index":0}]]},"Mistral Cloud Chat Model":{"ai_languageModel":[[{"node":"AI Agent","type":"ai_languageModel","index":0}]]},"Postgres Chat Memory":{"ai_memory":[[{"node":"AI Agent","type":"ai_memory","index":0}]]},"AI Agent":{"main":[[{"node":"Prepare Save","type":"main","index":0}]]},"Prepare Save":{"main":[[{"node":"UPSERT Conversation","type":"main","index":0}]]},"UPSERT Conversation":{"main":[[{"node":"INSERT User Message","type":"main","index":0}]]},"INSERT User Message":{"main":[[{"node":"INSERT Assistant Message","type":"main","index":0}]]},"INSERT Assistant Message":{"main":[[{"node":"UPDATE Token Usage","type":"main","index":0}]]},"UPDATE Token Usage":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook Chat":"12","Verify JWT":"13","JWT Valid?":"14","Check Quota":"15","Prepare Quota":"16","Quota OK?":"17","Postgres Chat Memory":"18","Mistral Cloud Chat Model":"19","AI Agent":"20","Prepare Save":"21","UPSERT Conversation":"22","INSERT User Message":"23","INSERT Assistant Message":"24","UPDATE Token Usage":"25","Format Response":"26","Success":"27"},"Success",{},[],{"Postgres Chat Memory":"28","Mistral Cloud Chat Model":"29"},{},{},{"version":1,"establishedAt":1766770452979,"source":"30"},["31"],["32"],["33"],["34"],["35"],["36"],["37","38"],["39"],["40"],["41"],["42"],["43"],["44"],["45"],["46"],["47"],["48","49"],["50"],"webhook",{"startTime":1766770452979,"executionIndex":0,"source":"51","hints":"52","executionTime":0,"executionStatus":"53","data":"54"},{"startTime":1766770452979,"executionIndex":1,"source":"55","hints":"56","executionTime":3,"executionStatus":"53","data":"57"},{"startTime":1766770452983,"executionIndex":2,"source":"58","hints":"59","executionTime":0,"executionStatus":"53","data":"60"},{"startTime":1766770452983,"executionIndex":3,"source":"61","hints":"62","executionTime":6,"executionStatus":"53","data":"63"},{"startTime":1766770452990,"executionIndex":4,"source":"64","hints":"65","executionTime":3,"executionStatus":"53","data":"66"},{"startTime":1766770452993,"executionIndex":5,"source":"67","hints":"68","executionTime":0,"executionStatus":"53","data":"69"},{"startTime":1766770452996,"executionTime":7,"executionIndex":7,"executionStatus":"53","source":"70","data":"71","inputOverride":"72","metadata":"73"},{"startTime":1766770453417,"executionTime":5,"executionIndex":9,"executionStatus":"53","source":"74","data":"75","inputOverride":"76","metadata":"77"},{"startTime":1766770453018,"executionTime":399,"executionIndex":8,"executionStatus":"53","source":"78","data":"79","inputOverride":"80","metadata":"81"},{"startTime":1766770452993,"executionIndex":6,"source":"82","hints":"83","executionTime":429,"executionStatus":"53","data":"84"},{"startTime":1766770453422,"executionIndex":10,"source":"85","hints":"86","executionTime":5,"executionStatus":"53","data":"87"},{"startTime":1766770453427,"executionIndex":11,"source":"88","hints":"89","executionTime":4,"executionStatus":"53","data":"90"},{"startTime":1766770453431,"executionIndex":12,"source":"91","hints":"92","executionTime":4,"executionStatus":"53","data":"93"},{"startTime":1766770453436,"executionIndex":13,"source":"94","hints":"95","executionTime":2,"executionStatus":"53","data":"96"},{"startTime":1766770453438,"executionIndex":14,"source":"97","hints":"98","executionTime":4,"executionStatus":"53","data":"99"},{"startTime":1766770453442,"executionIndex":15,"source":"100","hints":"101","executionTime":2,"executionStatus":"53","data":"102"},{"startTime":1766770453444,"executionIndex":16,"source":"103","hints":"104","executionTime":1,"executionStatus":"53","data":"105"},{"subRun":"106"},{"subRun":"107"},{"subRun":"108"},[],[],"success",{"main":"109"},["110"],["111"],{"main":"112"},["113"],[],{"main":"114"},["115"],[],{"main":"116"},["117"],["118"],{"main":"119"},["120"],[],{"main":"121"},["122"],{"ai_memory":"123"},{"ai_memory":"124"},{"subRun":"106"},["125"],{"ai_memory":"126"},{"ai_memory":"127"},{"subRun":"107"},["128"],{"ai_languageModel":"129"},{"ai_languageModel":"130"},{"subRun":"108"},["131"],[],{"main":"132"},["133"],["134"],{"main":"135"},["136"],[],{"main":"137"},["138"],[],{"main":"139"},["140"],[],{"main":"141"},["142"],[],{"main":"143"},["144"],["145"],{"main":"146"},["147"],[],{"main":"148"},["149"],["150"],["151"],["152"],{"previousNode":"153"},{"message":"154","location":"155"},["156"],{"previousNode":"157"},["158","159"],{"previousNode":"160"},["161"],{"previousNode":"162"},{"message":"154","location":"155"},["163"],{"previousNode":"164"},["165","166"],{"previousNode":"167","previousNodeRun":0},["168"],["169"],{"previousNode":"167","previousNodeRun":0},["170"],["171"],{"previousNode":"167","previousNodeRun":0},["172"],["173"],{"previousNode":"174"},["175"],{"previousNode":"167"},{"message":"154","location":"155"},["176"],{"previousNode":"177"},["178"],{"previousNode":"179"},["180"],{"previousNode":"181"},["182"],{"previousNode":"183"},["184"],{"previousNode":"185"},{"message":"154","location":"155"},["186"],{"previousNode":"187"},["188"],{"node":"189","runIndex":0},{"node":"189","runIndex":1},{"node":"190","runIndex":0},["191"],"Webhook Chat","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["192"],"Verify JWT",["193"],[],"JWT Valid?",["194"],"Check Quota",["195"],"Prepare Quota",["196"],[],"AI Agent",["197"],["198"],["199"],["200"],["201"],["202"],"Quota OK?",["203"],["204"],"Prepare Save",["205"],"UPSERT Conversation",["206"],"INSERT User Message",["207"],"INSERT Assistant Message",["208"],"UPDATE Token Usage",["209"],"Format Response",["210"],"Postgres Chat Memory","Mistral Cloud Chat Model",{"json":"211","pairedItem":"212"},{"json":"213","pairedItem":"214"},{"json":"213","pairedItem":"215"},{"json":"216","pairedItem":"217"},{"json":"218","pairedItem":"219"},{"json":"218","pairedItem":"220"},{"json":"221"},{"json":"222"},{"json":"223"},{"json":"224"},{"json":"225"},{"json":"226"},{"json":"227","pairedItem":"228"},{"json":"229","pairedItem":"230"},{"json":"231","pairedItem":"232"},{"json":"233","pairedItem":"234"},{"json":"235","pairedItem":"236"},{"json":"237","pairedItem":"238"},{"json":"239","pairedItem":"240"},{"json":"239","pairedItem":"241"},{"headers":"242","params":"243","query":"244","body":"245","webhookUrl":"246","executionMode":"247"},{"item":0},{"valid":true,"user":"248","userId":1,"conversationId":"249","message":"250","sessionId":"251"},{"item":0},{"item":0},{"used_tokens":"252","quota_tokens":"253"},{"item":0},{"valid":true,"user":"254","userId":1,"conversationId":"249","message":"250","sessionId":"251","usedTokens":14263,"quotaTokens":50000,"quotaExceeded":false},{"item":0},{"item":0},{"action":"255","chatHistory":"256"},{"action":"255","values":"257"},{"action":"258","chatHistory":"259"},{"action":"258","input":"260","output":"261"},{"response":"262","tokenUsage":"263"},{"messages":"264","estimatedTokens":225,"options":"265"},{"output":"266"},{"item":0},{"userId":1,"conversationId":"249","message":"250","response":"266","tokensUsed":26,"newUsedTokens":14289,"tokensRemaining":35711,"quotaTokens":50000},{"item":0},{"success":true},["267"],{"success":true},["268"],{"success":true},["269"],{"success":true},["270"],{"success":true,"response":"266","tokens_used":26,"tokens_remaining":35711,"conversation_id":"249"},{"item":0},{"item":0},{"host":"271","x-real-ip":"272","x-forwarded-for":"272","x-forwarded-proto":"273","connection":"274","content-length":"275","sec-ch-ua-platform":"276","authorization":"277","sec-ch-ua":"278","sec-ch-ua-mobile":"279","user-agent":"280","accept":"281","dnt":"282","content-type":"283","origin":"284","sec-fetch-site":"285","sec-fetch-mode":"286","sec-fetch-dest":"287","referer":"288","accept-encoding":"289","accept-language":"290","cookie":"291","sec-gpc":"282"},{},{},{"conversation_id":"249","message":"250"},"http://localhost:5678/webhook/wibot/chat","production",{"userId":1,"username":"292","role":"293","iat":1766770086,"exp":1766856486},"963eb9f1-fdcc-4cd5-918b-29fae40c17a0","dsf ça va ?","1_963eb9f1-fdcc-4cd5-918b-29fae40c17a0","14263","50000",{"userId":1,"username":"292","role":"293","iat":1766770086,"exp":1766856486},"loadMemoryVariables",["294","295","296","297","298","299"],{"input":"250","system_message":"300","formatting_instructions":"301"},"saveContext",["302","303","304","305","306","307","308","309"],{"input":"250","system_message":"300","formatting_instructions":"301"},{"input":"250","system_message":"300","formatting_instructions":"301","chat_history":"256","output":"266"},{"generations":"310"},{"completionTokens":25,"promptTokens":232,"totalTokens":257},["311"],{"mistral_api_key":"312","model":"313","max_tokens":2048,"temperature":0.7,"metadata":"314"},"Bonjour ! Je vais très bien, merci de demander. 😊\\n\\nComment puis-je vous aider aujourd'hui ?",{"item":0},{"item":0},{"item":0},{"item":0},"localhost","172.20.0.1","http","close","83","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzAwODYsImV4cCI6MTc2Njg1NjQ4Nn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","?0","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","1","application/json","http://localhost:5173","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","khora","admin",{"lc":1,"type":"315","id":"316","kwargs":"317"},{"lc":1,"type":"315","id":"318","kwargs":"319"},{"lc":1,"type":"315","id":"320","kwargs":"321"},{"lc":1,"type":"315","id":"322","kwargs":"323"},{"lc":1,"type":"315","id":"324","kwargs":"325"},{"lc":1,"type":"315","id":"326","kwargs":"327"},"Tu es WIBOT, l'assistant IA interne de WIDIP, une entreprise francaise de services informatiques.\\n\\nTon role:\\n- Aider les employes WIDIP avec leurs questions techniques\\n- Fournir des reponses claires et professionnelles\\n- Utiliser le francais par defaut\\n- Etre concis mais complet\\n\\nStyle:\\n- Utilise le markdown pour formater tes reponses\\n- Mets le code dans des blocs avec le langage specifie\\n- Sois amical mais professionnel","IMPORTANT: For your response to user, you MUST use the `format_final_json_response` tool with your complete answer formatted according to the required schema. Do not attempt to format the JSON manually - always use this tool. Your response will be rejected if it is not properly formatted through this tool. Only use this tool once you are ready to provide your final answer.",{"lc":1,"type":"315","id":"328","kwargs":"329"},{"lc":1,"type":"315","id":"330","kwargs":"331"},{"lc":1,"type":"315","id":"332","kwargs":"333"},{"lc":1,"type":"315","id":"334","kwargs":"335"},{"lc":1,"type":"315","id":"336","kwargs":"337"},{"lc":1,"type":"315","id":"338","kwargs":"339"},{"lc":1,"type":"315","id":"340","kwargs":"341"},{"lc":1,"type":"315","id":"342","kwargs":"343"},["344"],"System: Tu es WIBOT, l'assistant IA interne de WIDIP, une entreprise francaise de services informatiques.\\n\\nTon role:\\n- Aider les employes WIDIP avec leurs questions techniques\\n- Fournir des reponses claires et professionnelles\\n- Utiliser le francais par defaut\\n- Etre concis mais complet\\n\\nStyle:\\n- Utilise le markdown pour formater tes reponses\\n- Mets le code dans des blocs avec le langage specifie\\n- Sois amical mais professionnel\\nHuman: quel est le chiffre important que je t'ai donné ?\\nAI: Je n'ai pas de mémoire persistante entre nos interactions, donc je ne peux pas me souvenir des informations partagées lors de nos précédentes conversations. Si vous me donnez à nouveau le chiffre important, je serai ravi de vous aider avec celui-ci.\\n\\nN'hésitez pas à me le communiquer !\\nHuman: salut\\nAI: Salut ! Comment puis-je vous aider aujourd'hui ? 😊\\nHuman: salut\\nAI: Bonjour ! Comment puis-je vous aider aujourd'hui ? 😊\\nHuman: dsf ça va ?",{"lc":1,"type":"345","id":"346"},"mistral-small-latest",{},"constructor",["347","348","349"],{"content":"350","additional_kwargs":"351","response_metadata":"352"},["347","348","353"],{"content":"354","tool_calls":"355","additional_kwargs":"356","response_metadata":"357","invalid_tool_calls":"358"},["347","348","349"],{"content":"359","additional_kwargs":"360","response_metadata":"361"},["347","348","353"],{"content":"362","tool_calls":"363","additional_kwargs":"364","response_metadata":"365","invalid_tool_calls":"366"},["347","348","349"],{"content":"359","additional_kwargs":"367","response_metadata":"368"},["347","348","353"],{"content":"369","tool_calls":"370","additional_kwargs":"371","response_metadata":"372","invalid_tool_calls":"373"},["347","348","349"],{"content":"350","additional_kwargs":"374","response_metadata":"375"},["347","348","353"],{"content":"354","tool_calls":"376","additional_kwargs":"377","response_metadata":"378","invalid_tool_calls":"379"},["347","348","349"],{"content":"359","additional_kwargs":"380","response_metadata":"381"},["347","348","353"],{"content":"362","tool_calls":"382","additional_kwargs":"383","response_metadata":"384","invalid_tool_calls":"385"},["347","348","349"],{"content":"359","additional_kwargs":"386","response_metadata":"387"},["347","348","353"],{"content":"369","tool_calls":"388","additional_kwargs":"389","response_metadata":"390","invalid_tool_calls":"391"},["347","348","349"],{"content":"250","additional_kwargs":"392","response_metadata":"393"},["347","348","353"],{"content":"266","tool_calls":"394","additional_kwargs":"395","response_metadata":"396","invalid_tool_calls":"397"},["398"],"secret",["399"],"langchain_core","messages","HumanMessage","quel est le chiffre important que je t'ai donné ?",{},{},"AIMessage","Je n'ai pas de mémoire persistante entre nos interactions, donc je ne peux pas me souvenir des informations partagées lors de nos précédentes conversations. Si vous me donnez à nouveau le chiffre important, je serai ravi de vous aider avec celui-ci.\\n\\nN'hésitez pas à me le communiquer !",[],{},{},[],"salut",{},{},"Salut ! Comment puis-je vous aider aujourd'hui ? 😊",[],{},{},[],{},{},"Bonjour ! Comment puis-je vous aider aujourd'hui ? 😊",[],{},{},[],{},{},[],{},{},[],{},{},[],{},{},[],{},{},[],{},{},[],{},{},[],{},{},[],{"text":"266","generationInfo":"400"},"MISTRAL_API_KEY",{"prompt":0,"completion":0}]
86	{"id":"yPYTzGXVRP2JQxs8","name":"WIBOT - Get Conversations","active":true,"activeVersionId":"e1bae720-4a31-4afe-a595-4a35f7e26b0f","isArchived":false,"createdAt":"2025-12-26T17:23:46.197Z","updatedAt":"2025-12-26T17:24:07.735Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/conversations","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"c0f9fbaf-d0bb-4e86-92e9-c3e34e750679","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-656,112],"webhookId":"wibot-conversations"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"a5bd8ac1-82cc-4021-8420-752f46440f49","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"352ea961-e9a7-4651-acad-b594ba9f1c8c","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"9a0fd5d7-2e41-4111-b2b2-f84c1403ea28","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  c.conversation_id::text,\\n  c.title,\\n  TO_CHAR(c.updated_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as updated_at,\\n  COUNT(m.message_id)::integer as message_count\\nFROM conversations c\\nLEFT JOIN messages m ON c.conversation_id = m.conversation_id\\nWHERE c.user_id = {{ $json.userId }}\\nGROUP BY c.conversation_id, c.title, c.updated_at\\nORDER BY c.updated_at DESC\\nLIMIT 50;","options":{}},"id":"8fe150d4-0f4e-41ac-bd90-8978f31f4459","name":"Get Conversations","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[0,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats ou resultats vides\\nif (!rows || rows.length === 0 || !rows[0].json.conversation_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      conversations: []\\n    }\\n  }];\\n}\\n\\nconst conversations = rows.map(row => ({\\n  conversation_id: row.json.conversation_id,\\n  title: row.json.title || 'Nouvelle conversation',\\n  updated_at: row.json.updated_at,\\n  message_count: parseInt(row.json.message_count) || 0\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    conversations\\n  }\\n}];","notice":""},"id":"8d9137c5-9aa8-4938-961f-50bdbc93ee8f","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"463fcf83-1d8e-472a-94df-623b505f1a5d","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[448,0]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Conversations","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Conversations":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Unauthorized":"15"},"Unauthorized",{},[],{},{},{},{"version":1,"establishedAt":1766771189903,"source":"16"},["17"],["18"],["19"],["20"],"webhook",{"startTime":1766771189903,"executionIndex":0,"source":"21","hints":"22","executionTime":1,"executionStatus":"23","data":"24"},{"startTime":1766771189904,"executionIndex":1,"source":"25","hints":"26","executionTime":12,"executionStatus":"23","data":"27"},{"startTime":1766771189916,"executionIndex":2,"source":"28","hints":"29","executionTime":3,"executionStatus":"23","data":"30"},{"startTime":1766771189919,"executionIndex":3,"source":"31","hints":"32","executionTime":4,"executionStatus":"23","data":"33"},[],[],"success",{"main":"34"},["35"],["36"],{"main":"37"},["38"],[],{"main":"39"},["40"],[],{"main":"41"},["42"],{"previousNode":"43"},{"message":"44","location":"45"},["46"],{"previousNode":"47"},["48","49"],{"previousNode":"50","previousNodeOutput":1},["51"],["52"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["53"],"Verify JWT",[],["54"],"JWT Valid?",["55"],{"json":"56","pairedItem":"57"},{"json":"58","pairedItem":"59"},{"json":"58","pairedItem":"60"},{"json":"58","pairedItem":"61"},{"headers":"62","params":"63","query":"64","body":"65","webhookUrl":"66","executionMode":"67"},{"item":0},{"valid":false,"error":"68"},{"item":0},{"item":0},{"item":0},{"host":"69","x-real-ip":"70","x-forwarded-for":"70","x-forwarded-proto":"71","connection":"72","user-agent":"73","accept":"74","authorization":"75"},{},{},{},"http://localhost:5678/webhook/wibot/conversations","production","Invalid token format","localhost","172.20.0.1","http","close","curl/8.12.1","*/*","Bearer test"]
87	{"id":"msg5c740bd9db51","name":"WIBOT - Get Messages","active":true,"activeVersionId":"704bc444-e5e2-4901-9322-383bc1bd0434","isArchived":false,"createdAt":"2025-12-26T17:58:10.218Z","updatedAt":"2025-12-26T17:58:10.218Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/messages","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"webhook-messages","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,300],"webhookId":"wibot-messages"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst conversationId = $input.first().json.query.conversationId;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nif (!conversationId) {\\n  return [{ json: { valid: false, error: 'conversationId is required' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId, conversationId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"verify-jwt","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[470,300]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"if-jwt-valid","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[690,300]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-unauthorized","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[910,450]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  m.message_id,\\n  m.role,\\n  m.content,\\n  TO_CHAR(m.created_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as created_at\\nFROM messages m\\nJOIN conversations c ON m.conversation_id = c.conversation_id\\nWHERE m.conversation_id = '{{ $json.conversationId }}'::uuid\\n  AND c.user_id = {{ $json.userId }}\\nORDER BY m.created_at ASC;","options":{}},"id":"get-messages","name":"Get Messages","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[910,200],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats, retourner liste vide\\nif (!rows || rows.length === 0 || !rows[0].json.message_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      messages: []\\n    }\\n  }];\\n}\\n\\nconst messages = rows.map(row => ({\\n  message_id: row.json.message_id,\\n  role: row.json.role,\\n  content: row.json.content,\\n  created_at: row.json.created_at\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    messages\\n  }\\n}];","notice":""},"id":"format-response","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1130,200]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-success","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1350,200]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Messages","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Messages":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Unauthorized":"15"},"Unauthorized",{},[],{},{},{},{"version":1,"establishedAt":1766772056378,"source":"16"},["17"],["18"],["19"],["20"],"webhook",{"startTime":1766772056379,"executionIndex":0,"source":"21","hints":"22","executionTime":0,"executionStatus":"23","data":"24"},{"startTime":1766772056380,"executionIndex":1,"source":"25","hints":"26","executionTime":12,"executionStatus":"23","data":"27"},{"startTime":1766772056392,"executionIndex":2,"source":"28","hints":"29","executionTime":2,"executionStatus":"23","data":"30"},{"startTime":1766772056394,"executionIndex":3,"source":"31","hints":"32","executionTime":5,"executionStatus":"23","data":"33"},[],[],"success",{"main":"34"},["35"],["36"],{"main":"37"},["38"],[],{"main":"39"},["40"],[],{"main":"41"},["42"],{"previousNode":"43"},{"message":"44","location":"45"},["46"],{"previousNode":"47"},["48","49"],{"previousNode":"50","previousNodeOutput":1},["51"],["52"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["53"],"Verify JWT",[],["54"],"JWT Valid?",["55"],{"json":"56","pairedItem":"57"},{"json":"58","pairedItem":"59"},{"json":"58","pairedItem":"60"},{"json":"58","pairedItem":"61"},{"headers":"62","params":"63","query":"64","body":"65","webhookUrl":"66","executionMode":"67"},{"item":0},{"valid":false,"error":"68"},{"item":0},{"item":0},{"item":0},{"host":"69","x-real-ip":"70","x-forwarded-for":"70","x-forwarded-proto":"71","connection":"72","user-agent":"73","accept":"74","authorization":"75"},{},{"conversationId":"76"},{},"http://localhost:5678/webhook/wibot/messages","production","Invalid token format","localhost","172.20.0.1","http","close","curl/8.12.1","*/*","Bearer test","test123"]
88	{"id":"zZSHB9BHjR30ThPP","name":"WIBOT - Auth Login","active":true,"activeVersionId":"1e31f7d7-5e68-47eb-863c-91d1ec7b0819","isArchived":false,"createdAt":"2025-12-26T17:23:18.804Z","updatedAt":"2025-12-26T17:24:10.395Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"POST","path":"auth/login","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"c8898033-10a2-436a-915d-a01f108756c6","name":"Webhook Login","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-1104,208],"webhookId":"auth-login"},{"parameters":{"resource":"database","operation":"select","schema":"public","table":"users","returnAll":false,"limit":1,"where":{"values":[{"column":"username","condition":"equal","value":"={{ $json.body.username }}"},{"column":"is_active","condition":"equal","value":"true"}]},"combineConditions":"AND","sort":{},"options":{}},"id":"a2a158de-b676-468b-a23e-18466966d674","name":"Get User","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[-880,208],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-user-exists","leftValue":"={{ $json.user_id }}","rightValue":"","operator":{"type":"exists","operation":"exists"}}],"combinator":"and"},"options":{}},"id":"dd3f022d-09ed-47fe-ba59-73ae33165762","name":"User Exists?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-656,208]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const inputPassword = $('Webhook Login').first().json.body.password;\\nconst storedHash = $input.first().json.password_hash;\\nconst user = $input.first().json;\\n\\n// Comparaison simple du mot de passe\\nconst isValid = (inputPassword === storedHash);\\n\\nreturn [{ json: { isValid, user } }];","notice":""},"id":"bb41f913-1c3c-4afb-88a4-c46324c2b9ec","name":"Verify Password","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-password-valid","leftValue":"={{ $json.isValid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"73c0896e-95a9-4677-86c9-3398d7856fad","name":"Password Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const user = $input.first().json.user;\\n\\n// Fonction base64 encode compatible n8n\\nfunction toBase64(str) {\\n  return Buffer.from(str).toString('base64').replace(/=/g, '').replace(/\\\\+/g, '-').replace(/\\\\//g, '_');\\n}\\n\\nconst header = toBase64(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));\\n\\nconst payload = toBase64(JSON.stringify({\\n  userId: user.user_id,\\n  username: user.username,\\n  role: user.role,\\n  iat: Math.floor(Date.now() / 1000),\\n  exp: Math.floor(Date.now() / 1000) + (24 * 60 * 60)\\n}));\\n\\n// Signature simplifiée\\nconst signature = toBase64(header + payload + 'wibot_secret').substring(0, 43);\\n\\nconst token = `${header}.${payload}.${signature}`;\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    token,\\n    user: {\\n      id: user.user_id,\\n      username: user.username,\\n      role: user.role\\n    }\\n  }\\n}];","notice":""},"id":"56756190-1aeb-4413-946a-e2a7b4907e8e","name":"Generate JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[0,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"5e5d60cc-5fee-4f26-b838-71d66c7a885a","name":"Success Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[224,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"Invalid credentials\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"e90d3bbc-527a-4b00-b1dc-9bb17afa5966","name":"Invalid Password","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,208]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"User not found\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"8423d2d4-a607-49d0-a6d7-8730cf78fd86","name":"User Not Found","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[-448,304]}],"connections":{"Webhook Login":{"main":[[{"node":"Get User","type":"main","index":0}]]},"Get User":{"main":[[{"node":"User Exists?","type":"main","index":0}]]},"User Exists?":{"main":[[{"node":"Verify Password","type":"main","index":0}],[{"node":"User Not Found","type":"main","index":0}]]},"Verify Password":{"main":[[{"node":"Password Valid?","type":"main","index":0}]]},"Password Valid?":{"main":[[{"node":"Generate JWT","type":"main","index":0}],[{"node":"Invalid Password","type":"main","index":0}]]},"Generate JWT":{"main":[[{"node":"Success Response","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook Login":"12","Get User":"13","User Exists?":"14","Verify Password":"15","Password Valid?":"16","Invalid Password":"17"},"Invalid Password",{},[],{},{},{},{"version":1,"establishedAt":1766772070565,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766772070565,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766772070565,"executionIndex":1,"source":"29","hints":"30","executionTime":31,"executionStatus":"27","data":"31"},{"startTime":1766772070596,"executionIndex":2,"source":"32","hints":"33","executionTime":3,"executionStatus":"27","data":"34"},{"startTime":1766772070599,"executionIndex":3,"source":"35","hints":"36","executionTime":4,"executionStatus":"27","data":"37"},{"startTime":1766772070603,"executionIndex":4,"source":"38","hints":"39","executionTime":2,"executionStatus":"27","data":"40"},{"startTime":1766772070606,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],[],{"main":"46"},["47"],[],{"main":"48"},["49"],["50"],{"main":"51"},["52"],[],{"main":"53"},["54"],[],{"main":"55"},["56"],{"previousNode":"57"},["58"],{"previousNode":"59"},["60","61"],{"previousNode":"62"},{"message":"63","location":"64"},["65"],{"previousNode":"66"},["67","68"],{"previousNode":"69","previousNodeOutput":1},["70"],["71"],"Webhook Login",["72"],"Get User",["73"],[],"User Exists?","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["74"],"Verify Password",[],["75"],"Password Valid?",["76"],{"json":"77","pairedItem":"78"},{"json":"79","pairedItem":"80"},{"json":"79","pairedItem":"81"},{"json":"82","pairedItem":"83"},{"json":"82","pairedItem":"84"},{"json":"82","pairedItem":"85"},{"headers":"86","params":"87","query":"88","body":"89","webhookUrl":"90","executionMode":"91"},{"item":0},{"user_id":1,"username":"92","password_hash":"93","email":"94","role":"95","created_at":"96","is_active":true},{"item":0},{"item":0},{"isValid":false,"user":"97"},{"item":0},{"item":0},{"item":0},{"host":"98","x-real-ip":"99","x-forwarded-for":"99","x-forwarded-proto":"100","connection":"101","content-length":"102","user-agent":"103","accept":"104","content-type":"105"},{},{},{"username":"92","password":"106"},"http://localhost:5678/webhook/auth/login","production","khora","test123","khora@widip.fr","admin","2025-12-26T06:42:15.244Z",{"user_id":1,"username":"92","password_hash":"93","email":"94","role":"95","created_at":"96","is_active":true},"localhost","172.20.0.1","http","close","44","curl/8.12.1","*/*","application/json","Widip@2025"]
89	{"id":"zZSHB9BHjR30ThPP","name":"WIBOT - Auth Login","active":true,"activeVersionId":"1e31f7d7-5e68-47eb-863c-91d1ec7b0819","isArchived":false,"createdAt":"2025-12-26T17:23:18.804Z","updatedAt":"2025-12-26T17:24:10.395Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"POST","path":"auth/login","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"c8898033-10a2-436a-915d-a01f108756c6","name":"Webhook Login","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-1104,208],"webhookId":"auth-login"},{"parameters":{"resource":"database","operation":"select","schema":"public","table":"users","returnAll":false,"limit":1,"where":{"values":[{"column":"username","condition":"equal","value":"={{ $json.body.username }}"},{"column":"is_active","condition":"equal","value":"true"}]},"combineConditions":"AND","sort":{},"options":{}},"id":"a2a158de-b676-468b-a23e-18466966d674","name":"Get User","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[-880,208],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-user-exists","leftValue":"={{ $json.user_id }}","rightValue":"","operator":{"type":"exists","operation":"exists"}}],"combinator":"and"},"options":{}},"id":"dd3f022d-09ed-47fe-ba59-73ae33165762","name":"User Exists?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-656,208]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const inputPassword = $('Webhook Login').first().json.body.password;\\nconst storedHash = $input.first().json.password_hash;\\nconst user = $input.first().json;\\n\\n// Comparaison simple du mot de passe\\nconst isValid = (inputPassword === storedHash);\\n\\nreturn [{ json: { isValid, user } }];","notice":""},"id":"bb41f913-1c3c-4afb-88a4-c46324c2b9ec","name":"Verify Password","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-password-valid","leftValue":"={{ $json.isValid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"73c0896e-95a9-4677-86c9-3398d7856fad","name":"Password Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const user = $input.first().json.user;\\n\\n// Fonction base64 encode compatible n8n\\nfunction toBase64(str) {\\n  return Buffer.from(str).toString('base64').replace(/=/g, '').replace(/\\\\+/g, '-').replace(/\\\\//g, '_');\\n}\\n\\nconst header = toBase64(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));\\n\\nconst payload = toBase64(JSON.stringify({\\n  userId: user.user_id,\\n  username: user.username,\\n  role: user.role,\\n  iat: Math.floor(Date.now() / 1000),\\n  exp: Math.floor(Date.now() / 1000) + (24 * 60 * 60)\\n}));\\n\\n// Signature simplifiée\\nconst signature = toBase64(header + payload + 'wibot_secret').substring(0, 43);\\n\\nconst token = `${header}.${payload}.${signature}`;\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    token,\\n    user: {\\n      id: user.user_id,\\n      username: user.username,\\n      role: user.role\\n    }\\n  }\\n}];","notice":""},"id":"56756190-1aeb-4413-946a-e2a7b4907e8e","name":"Generate JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[0,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"5e5d60cc-5fee-4f26-b838-71d66c7a885a","name":"Success Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[224,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"Invalid credentials\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"e90d3bbc-527a-4b00-b1dc-9bb17afa5966","name":"Invalid Password","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,208]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"User not found\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"8423d2d4-a607-49d0-a6d7-8730cf78fd86","name":"User Not Found","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[-448,304]}],"connections":{"Webhook Login":{"main":[[{"node":"Get User","type":"main","index":0}]]},"Get User":{"main":[[{"node":"User Exists?","type":"main","index":0}]]},"User Exists?":{"main":[[{"node":"Verify Password","type":"main","index":0}],[{"node":"User Not Found","type":"main","index":0}]]},"Verify Password":{"main":[[{"node":"Password Valid?","type":"main","index":0}]]},"Password Valid?":{"main":[[{"node":"Generate JWT","type":"main","index":0}],[{"node":"Invalid Password","type":"main","index":0}]]},"Generate JWT":{"main":[[{"node":"Success Response","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook Login":"12","Get User":"13","User Exists?":"14","Verify Password":"15","Password Valid?":"16","Generate JWT":"17","Success Response":"18"},"Success Response",{},[],{},{},{},{"version":1,"establishedAt":1766772088395,"source":"19"},["20"],["21"],["22"],["23"],["24"],["25"],["26"],"webhook",{"startTime":1766772088395,"executionIndex":0,"source":"27","hints":"28","executionTime":0,"executionStatus":"29","data":"30"},{"startTime":1766772088395,"executionIndex":1,"source":"31","hints":"32","executionTime":9,"executionStatus":"29","data":"33"},{"startTime":1766772088404,"executionIndex":2,"source":"34","hints":"35","executionTime":0,"executionStatus":"29","data":"36"},{"startTime":1766772088404,"executionIndex":3,"source":"37","hints":"38","executionTime":3,"executionStatus":"29","data":"39"},{"startTime":1766772088407,"executionIndex":4,"source":"40","hints":"41","executionTime":0,"executionStatus":"29","data":"42"},{"startTime":1766772088407,"executionIndex":5,"source":"43","hints":"44","executionTime":6,"executionStatus":"29","data":"45"},{"startTime":1766772088413,"executionIndex":6,"source":"46","hints":"47","executionTime":3,"executionStatus":"29","data":"48"},[],[],"success",{"main":"49"},["50"],[],{"main":"51"},["52"],[],{"main":"53"},["54"],["55"],{"main":"56"},["57"],[],{"main":"58"},["59"],["60"],{"main":"61"},["62"],[],{"main":"63"},["64"],{"previousNode":"65"},["66"],{"previousNode":"67"},["68","69"],{"previousNode":"70"},{"message":"71","location":"72"},["73"],{"previousNode":"74"},["75","76"],{"previousNode":"77"},{"message":"71","location":"72"},["78"],{"previousNode":"79"},["80"],["81"],"Webhook Login",["82"],"Get User",["83"],[],"User Exists?","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["84"],"Verify Password",["85"],[],"Password Valid?",["86"],"Generate JWT",["87"],{"json":"88","pairedItem":"89"},{"json":"90","pairedItem":"91"},{"json":"90","pairedItem":"92"},{"json":"93","pairedItem":"94"},{"json":"93","pairedItem":"95"},{"json":"96","pairedItem":"97"},{"json":"96","pairedItem":"98"},{"headers":"99","params":"100","query":"101","body":"102","webhookUrl":"103","executionMode":"104"},{"item":0},{"user_id":1,"username":"105","password_hash":"106","email":"107","role":"108","created_at":"109","is_active":true},{"item":0},{"item":0},{"isValid":true,"user":"110"},{"item":0},{"item":0},{"success":true,"token":"111","user":"112"},{"item":0},{"item":0},{"host":"113","x-real-ip":"114","x-forwarded-for":"114","x-forwarded-proto":"115","connection":"116","content-length":"117","user-agent":"118","accept":"119","content-type":"120"},{},{},{"username":"105","password":"106"},"http://localhost:5678/webhook/auth/login","production","khora","test123","khora@widip.fr","admin","2025-12-26T06:42:15.244Z",{"user_id":1,"username":"105","password_hash":"106","email":"107","role":"108","created_at":"109","is_active":true},"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzIwODgsImV4cCI6MTc2Njg1ODQ4OH0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh",{"id":1,"username":"105","role":"108"},"localhost","172.20.0.1","http","close","41","curl/8.12.1","*/*","application/json"]
90	{"id":"msg5c740bd9db51","name":"WIBOT - Get Messages","active":true,"activeVersionId":"704bc444-e5e2-4901-9322-383bc1bd0434","isArchived":false,"createdAt":"2025-12-26T17:58:10.218Z","updatedAt":"2025-12-26T17:58:10.218Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/messages","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"webhook-messages","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,300],"webhookId":"wibot-messages"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst conversationId = $input.first().json.query.conversationId;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nif (!conversationId) {\\n  return [{ json: { valid: false, error: 'conversationId is required' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId, conversationId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"verify-jwt","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[470,300]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"if-jwt-valid","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[690,300]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-unauthorized","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[910,450]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  m.message_id,\\n  m.role,\\n  m.content,\\n  TO_CHAR(m.created_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as created_at\\nFROM messages m\\nJOIN conversations c ON m.conversation_id = c.conversation_id\\nWHERE m.conversation_id = '{{ $json.conversationId }}'::uuid\\n  AND c.user_id = {{ $json.userId }}\\nORDER BY m.created_at ASC;","options":{}},"id":"get-messages","name":"Get Messages","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[910,200],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats, retourner liste vide\\nif (!rows || rows.length === 0 || !rows[0].json.message_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      messages: []\\n    }\\n  }];\\n}\\n\\nconst messages = rows.map(row => ({\\n  message_id: row.json.message_id,\\n  role: row.json.role,\\n  content: row.json.content,\\n  created_at: row.json.created_at\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    messages\\n  }\\n}];","notice":""},"id":"format-response","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1130,200]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-success","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1350,200]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Messages","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Messages":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Messages":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766772103408,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766772103408,"executionIndex":0,"source":"25","hints":"26","executionTime":1,"executionStatus":"27","data":"28"},{"startTime":1766772103409,"executionIndex":1,"source":"29","hints":"30","executionTime":3,"executionStatus":"27","data":"31"},{"startTime":1766772103412,"executionIndex":2,"source":"32","hints":"33","executionTime":0,"executionStatus":"27","data":"34"},{"startTime":1766772103413,"executionIndex":3,"source":"35","hints":"36","executionTime":11,"executionStatus":"27","data":"37"},{"startTime":1766772103424,"executionIndex":4,"source":"38","hints":"39","executionTime":3,"executionStatus":"27","data":"40"},{"startTime":1766772103428,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75","76","77","78","79","80","81","82","83","84","85"],"Get Messages",["86"],"Format Response",["87"],{"json":"88","pairedItem":"89"},{"json":"90","pairedItem":"91"},{"json":"90","pairedItem":"92"},{"json":"93","pairedItem":"94"},{"json":"95","pairedItem":"94"},{"json":"96","pairedItem":"94"},{"json":"97","pairedItem":"94"},{"json":"98","pairedItem":"94"},{"json":"99","pairedItem":"94"},{"json":"100","pairedItem":"94"},{"json":"101","pairedItem":"94"},{"json":"102","pairedItem":"94"},{"json":"103","pairedItem":"94"},{"json":"104","pairedItem":"94"},{"json":"105","pairedItem":"94"},{"json":"106"},{"json":"106","pairedItem":"107"},{"headers":"108","params":"109","query":"110","body":"111","webhookUrl":"112","executionMode":"113"},{"item":0},{"valid":true,"userId":1,"conversationId":"114"},{"item":0},{"item":0},{"message_id":1,"role":"115","content":"116","created_at":"117"},{"item":0},{"message_id":2,"role":"118","content":"119","created_at":"120"},{"message_id":3,"role":"115","content":"121","created_at":"122"},{"message_id":4,"role":"118","content":"123","created_at":"124"},{"message_id":5,"role":"115","content":"125","created_at":"126"},{"message_id":6,"role":"118","content":"127","created_at":"128"},{"message_id":27,"role":"115","content":"129","created_at":"130"},{"message_id":28,"role":"118","content":"131","created_at":"130"},{"message_id":29,"role":"115","content":"132","created_at":"133"},{"message_id":30,"role":"118","content":"134","created_at":"133"},{"message_id":31,"role":"115","content":"135","created_at":"136"},{"message_id":32,"role":"118","content":"137","created_at":"136"},{"success":true,"messages":"138"},{"item":0},{"host":"139","x-real-ip":"140","x-forwarded-for":"140","x-forwarded-proto":"141","connection":"142","user-agent":"143","accept":"144","authorization":"145"},{},{"conversationId":"114"},{},"http://localhost:5678/webhook/wibot/messages","production","550e8400-e29b-41d4-a716-446655440000","user","Bonjour WIBOT !","2025-12-24T07:42:15Z","assistant","Bonjour ! Je suis WIBOT, l'assistant IA de WIDIP. Comment puis-je t'aider aujourd'hui ?","2025-12-24T07:42:17Z","Peux-tu m'expliquer comment fonctionne PostgreSQL ?","2025-12-24T07:43:15Z","PostgreSQL est un systeme de gestion de base de donnees relationnelle (SGBDR) open source tres puissant.\\n\\n**Caracteristiques principales :**\\n- Support complet SQL\\n- Transactions ACID\\n- Extensions (comme pgcrypto pour le chiffrement)\\n- Excellent pour les charges de travail complexes\\n\\nC'est ce qu'on utilise chez WIDIP pour stocker les donnees WIBOT !","2025-12-24T07:43:20Z","Et comment faire un backup ?","2025-12-25T07:42:15Z","Pour faire un backup PostgreSQL, tu as plusieurs options :\\n\\n```bash\\n# Backup complet (dump SQL)\\npg_dump -U widip -d wibot > backup.sql\\n\\n# Backup compresse\\npg_dump -U widip -d wibot | gzip > backup.sql.gz\\n\\n# Restauration\\npsql -U widip -d wibot < backup.sql\\n```\\n\\nPour les backups automatiques, on peut utiliser un cron job ou un workflow n8n !","2025-12-25T07:42:18Z","salut","2025-12-26T17:16:30Z","Salut ! Comment puis-je vous aider aujourd'hui ?","ddadzax","2025-12-26T17:16:38Z","Bonjour ! Je ne suis pas sûr de comprendre votre demande. Pourriez-vous préciser ou reformuler votre question ? Je suis là pour vous aider avec les questions techniques ou toute autre demande liée à WIDIP.","hey","2025-12-26T17:28:13Z","Bonjour ! Comment puis-je vous aider aujourd'hui ?",["146","147","148","149","150","151","152","153","154","155","156","157"],"localhost","172.20.0.1","http","close","curl/8.12.1","*/*","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzIwODgsImV4cCI6MTc2Njg1ODQ4OH0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh",{"message_id":1,"role":"115","content":"116","created_at":"117"},{"message_id":2,"role":"118","content":"119","created_at":"120"},{"message_id":3,"role":"115","content":"121","created_at":"122"},{"message_id":4,"role":"118","content":"123","created_at":"124"},{"message_id":5,"role":"115","content":"125","created_at":"126"},{"message_id":6,"role":"118","content":"127","created_at":"128"},{"message_id":27,"role":"115","content":"129","created_at":"130"},{"message_id":28,"role":"118","content":"131","created_at":"130"},{"message_id":29,"role":"115","content":"132","created_at":"133"},{"message_id":30,"role":"118","content":"134","created_at":"133"},{"message_id":31,"role":"115","content":"135","created_at":"136"},{"message_id":32,"role":"118","content":"137","created_at":"136"}]
92	{"id":"msg5c740bd9db51","name":"WIBOT - Get Messages","active":true,"activeVersionId":"704bc444-e5e2-4901-9322-383bc1bd0434","isArchived":false,"createdAt":"2025-12-26T17:58:10.218Z","updatedAt":"2025-12-26T17:58:10.218Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/messages","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"webhook-messages","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,300],"webhookId":"wibot-messages"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst conversationId = $input.first().json.query.conversationId;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nif (!conversationId) {\\n  return [{ json: { valid: false, error: 'conversationId is required' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId, conversationId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"verify-jwt","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[470,300]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"if-jwt-valid","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[690,300]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-unauthorized","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[910,450]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  m.message_id,\\n  m.role,\\n  m.content,\\n  TO_CHAR(m.created_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as created_at\\nFROM messages m\\nJOIN conversations c ON m.conversation_id = c.conversation_id\\nWHERE m.conversation_id = '{{ $json.conversationId }}'::uuid\\n  AND c.user_id = {{ $json.userId }}\\nORDER BY m.created_at ASC;","options":{}},"id":"get-messages","name":"Get Messages","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[910,200],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats, retourner liste vide\\nif (!rows || rows.length === 0 || !rows[0].json.message_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      messages: []\\n    }\\n  }];\\n}\\n\\nconst messages = rows.map(row => ({\\n  message_id: row.json.message_id,\\n  role: row.json.role,\\n  content: row.json.content,\\n  created_at: row.json.created_at\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    messages\\n  }\\n}];","notice":""},"id":"format-response","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1130,200]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-success","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1350,200]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Messages","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Messages":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Messages":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766772118343,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766772118343,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766772118343,"executionIndex":1,"source":"29","hints":"30","executionTime":4,"executionStatus":"27","data":"31"},{"startTime":1766772118347,"executionIndex":2,"source":"32","hints":"33","executionTime":1,"executionStatus":"27","data":"34"},{"startTime":1766772118348,"executionIndex":3,"source":"35","hints":"36","executionTime":2,"executionStatus":"27","data":"37"},{"startTime":1766772118351,"executionIndex":4,"source":"38","hints":"39","executionTime":2,"executionStatus":"27","data":"40"},{"startTime":1766772118353,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75","76","77","78","79","80","81"],"Get Messages",["82"],"Format Response",["83"],{"json":"84","pairedItem":"85"},{"json":"86","pairedItem":"87"},{"json":"86","pairedItem":"88"},{"json":"89","pairedItem":"90"},{"json":"91","pairedItem":"90"},{"json":"92","pairedItem":"90"},{"json":"93","pairedItem":"90"},{"json":"94","pairedItem":"90"},{"json":"95","pairedItem":"90"},{"json":"96","pairedItem":"90"},{"json":"97","pairedItem":"90"},{"json":"98"},{"json":"98","pairedItem":"99"},{"headers":"100","params":"101","query":"102","body":"103","webhookUrl":"104","executionMode":"105"},{"item":0},{"valid":true,"userId":1,"conversationId":"106"},{"item":0},{"item":0},{"message_id":21,"role":"107","content":"108","created_at":"109"},{"item":0},{"message_id":22,"role":"110","content":"111","created_at":"109"},{"message_id":23,"role":"107","content":"112","created_at":"113"},{"message_id":24,"role":"110","content":"114","created_at":"113"},{"message_id":25,"role":"107","content":"112","created_at":"115"},{"message_id":26,"role":"110","content":"116","created_at":"115"},{"message_id":33,"role":"107","content":"117","created_at":"118"},{"message_id":34,"role":"110","content":"119","created_at":"118"},{"success":true,"messages":"120"},{"item":0},{"host":"121","x-real-ip":"122","x-forwarded-for":"122","x-forwarded-proto":"123","connection":"124","user-agent":"125","accept":"126","authorization":"127"},{},{"conversationId":"106"},{},"http://localhost:5678/webhook/wibot/messages","production","963eb9f1-fdcc-4cd5-918b-29fae40c17a0","user","quel est le chiffre important que je t'ai donné ?","2025-12-26T16:45:37Z","assistant","Je n'ai pas de mémoire persistante entre nos interactions, donc je ne peux pas me souvenir des informations partagées lors de nos précédentes conversations. Si vous me donnez à nouveau le chiffre important, je serai ravi de vous aider avec celui-ci.\\n\\nN'hésitez pas à me le communiquer !","salut","2025-12-26T17:13:49Z","Salut ! Comment puis-je vous aider aujourd'hui ? 😊","2025-12-26T17:14:33Z","Bonjour ! Comment puis-je vous aider aujourd'hui ? 😊","dsf ça va ?","2025-12-26T17:34:13Z","Bonjour ! Je vais très bien, merci de demander. 😊\\n\\nComment puis-je vous aider aujourd'hui ?",["128","129","130","131","132","133","134","135"],"localhost","172.20.0.1","http","close","curl/8.12.1","*/*","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzIwODgsImV4cCI6MTc2Njg1ODQ4OH0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh",{"message_id":21,"role":"107","content":"108","created_at":"109"},{"message_id":22,"role":"110","content":"111","created_at":"109"},{"message_id":23,"role":"107","content":"112","created_at":"113"},{"message_id":24,"role":"110","content":"114","created_at":"113"},{"message_id":25,"role":"107","content":"112","created_at":"115"},{"message_id":26,"role":"110","content":"116","created_at":"115"},{"message_id":33,"role":"107","content":"117","created_at":"118"},{"message_id":34,"role":"110","content":"119","created_at":"118"}]
93	{"id":"yPYTzGXVRP2JQxs8","name":"WIBOT - Get Conversations","active":true,"activeVersionId":"e1bae720-4a31-4afe-a595-4a35f7e26b0f","isArchived":false,"createdAt":"2025-12-26T17:23:46.197Z","updatedAt":"2025-12-26T17:24:07.735Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/conversations","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"c0f9fbaf-d0bb-4e86-92e9-c3e34e750679","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-656,112],"webhookId":"wibot-conversations"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"a5bd8ac1-82cc-4021-8420-752f46440f49","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"352ea961-e9a7-4651-acad-b594ba9f1c8c","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"9a0fd5d7-2e41-4111-b2b2-f84c1403ea28","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  c.conversation_id::text,\\n  c.title,\\n  TO_CHAR(c.updated_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as updated_at,\\n  COUNT(m.message_id)::integer as message_count\\nFROM conversations c\\nLEFT JOIN messages m ON c.conversation_id = m.conversation_id\\nWHERE c.user_id = {{ $json.userId }}\\nGROUP BY c.conversation_id, c.title, c.updated_at\\nORDER BY c.updated_at DESC\\nLIMIT 50;","options":{}},"id":"8fe150d4-0f4e-41ac-bd90-8978f31f4459","name":"Get Conversations","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[0,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats ou resultats vides\\nif (!rows || rows.length === 0 || !rows[0].json.conversation_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      conversations: []\\n    }\\n  }];\\n}\\n\\nconst conversations = rows.map(row => ({\\n  conversation_id: row.json.conversation_id,\\n  title: row.json.title || 'Nouvelle conversation',\\n  updated_at: row.json.updated_at,\\n  message_count: parseInt(row.json.message_count) || 0\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    conversations\\n  }\\n}];","notice":""},"id":"8d9137c5-9aa8-4938-961f-50bdbc93ee8f","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"463fcf83-1d8e-472a-94df-623b505f1a5d","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[448,0]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Conversations","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Conversations":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Conversations":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766772148579,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766772148579,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766772148579,"executionIndex":1,"source":"29","hints":"30","executionTime":3,"executionStatus":"27","data":"31"},{"startTime":1766772148582,"executionIndex":2,"source":"32","hints":"33","executionTime":1,"executionStatus":"27","data":"34"},{"startTime":1766772148583,"executionIndex":3,"source":"35","hints":"36","executionTime":13,"executionStatus":"27","data":"37"},{"startTime":1766772148596,"executionIndex":4,"source":"38","hints":"39","executionTime":2,"executionStatus":"27","data":"40"},{"startTime":1766772148599,"executionIndex":5,"source":"41","hints":"42","executionTime":0,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75","76"],"Get Conversations",["77"],"Format Response",["78"],{"json":"79","pairedItem":"80"},{"json":"81","pairedItem":"82"},{"json":"81","pairedItem":"83"},{"json":"84","pairedItem":"85"},{"json":"86","pairedItem":"85"},{"json":"87","pairedItem":"85"},{"json":"88"},{"json":"88","pairedItem":"89"},{"headers":"90","params":"91","query":"92","body":"93","webhookUrl":"94","executionMode":"95"},{"item":0},{"valid":true,"userId":1},{"item":0},{"item":0},{"conversation_id":"96","title":"97","updated_at":"98","message_count":8},{"item":0},{"conversation_id":"99","title":"100","updated_at":"101","message_count":12},{"conversation_id":"102","title":"103","updated_at":"104","message_count":14},{"success":true,"conversations":"105"},{"item":0},{"host":"106","x-real-ip":"107","x-forwarded-for":"107","x-forwarded-proto":"108","connection":"109","sec-ch-ua-platform":"110","authorization":"111","user-agent":"112","accept":"113","sec-ch-ua":"114","dnt":"115","sec-ch-ua-mobile":"116","sec-fetch-site":"117","sec-fetch-mode":"118","sec-fetch-dest":"119","referer":"120","accept-encoding":"121","accept-language":"122","cookie":"123","sec-gpc":"115","if-none-match":"124"},{},{},{},"http://localhost:5678/webhook/wibot/conversations","production","963eb9f1-fdcc-4cd5-918b-29fae40c17a0","quel est le chiffre important que je t'ai donné ?","2025-12-26T17:34:13Z","550e8400-e29b-41d4-a716-446655440000","Conversation de test","2025-12-26T17:28:13Z","3cc2c8db-afef-4637-accc-31d259f53857","saluty","2025-12-26T16:45:24Z",["125","126","127"],"localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzAwODYsImV4cCI6MTc2Njg1NjQ4Nn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","W/\\"1e4-MqKK+LhPKkKdZuMcKXFAhwJvpyg\\"",{"conversation_id":"96","title":"97","updated_at":"98","message_count":8},{"conversation_id":"99","title":"100","updated_at":"101","message_count":12},{"conversation_id":"102","title":"103","updated_at":"104","message_count":14}]
94	{"id":"c8fbjjX9ObuzBE4b","name":"WIBOT - Get User Tokens","active":true,"activeVersionId":"62643582-5e10-4f85-9c6c-74a85d102e67","isArchived":false,"createdAt":"2025-12-26T17:24:01.471Z","updatedAt":"2025-12-26T17:24:05.529Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/user/tokens","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"8fcee23f-b3e4-4c28-ad04-4ba456f7752a","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-656,112],"webhookId":"wibot-user-tokens"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"d8de2cd5-94e4-49a5-a318-1ee1c389abd9","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"c9c309e4-53ba-46be-8960-13da82f4f5f7","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"83cd3ac8-fb46-4de5-a8ce-5d24be08334c","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  COALESCE(used_tokens, 0) as used_tokens,\\n  COALESCE(quota_tokens, 50000) as quota_tokens,\\n  COALESCE(quota_tokens, 50000) - COALESCE(used_tokens, 0) as tokens_remaining\\nFROM user_token_usage\\nWHERE user_id = {{ $json.userId }}\\n  AND month = DATE_TRUNC('month', CURRENT_DATE)\\nLIMIT 1;","options":{}},"id":"b35fa964-24c4-49ed-a3b6-7df917662ceb","name":"Get Token Usage","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[0,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\nconst jwtData = $('Verify JWT').first().json;\\n\\n// Si pas de donnees, l'utilisateur n'a pas encore utilise de tokens ce mois\\nif (!rows || rows.length === 0 || rows[0].json.tokens_remaining === undefined) {\\n  return [{\\n    json: {\\n      success: true,\\n      used_tokens: 0,\\n      quota_tokens: 50000,\\n      tokens_remaining: 50000\\n    }\\n  }];\\n}\\n\\nconst data = rows[0].json;\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    used_tokens: parseInt(data.used_tokens) || 0,\\n    quota_tokens: parseInt(data.quota_tokens) || 50000,\\n    tokens_remaining: parseInt(data.tokens_remaining) || 50000\\n  }\\n}];","notice":""},"id":"7d9b1764-6fed-49d3-957f-402aa7f05696","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"67daad4e-a2fe-4b36-b18c-065181b80de3","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[448,0]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Token Usage","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Token Usage":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Token Usage":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766772148592,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766772148593,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766772148593,"executionIndex":1,"source":"29","hints":"30","executionTime":2,"executionStatus":"27","data":"31"},{"startTime":1766772148595,"executionIndex":2,"source":"32","hints":"33","executionTime":1,"executionStatus":"27","data":"34"},{"startTime":1766772148596,"executionIndex":3,"source":"35","hints":"36","executionTime":7,"executionStatus":"27","data":"37"},{"startTime":1766772148603,"executionIndex":4,"source":"38","hints":"39","executionTime":3,"executionStatus":"27","data":"40"},{"startTime":1766772148606,"executionIndex":5,"source":"41","hints":"42","executionTime":2,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74"],"Get Token Usage",["75"],"Format Response",["76"],{"json":"77","pairedItem":"78"},{"json":"79","pairedItem":"80"},{"json":"79","pairedItem":"81"},{"json":"82","pairedItem":"83"},{"json":"84","pairedItem":"85"},{"json":"84","pairedItem":"86"},{"headers":"87","params":"88","query":"89","body":"90","webhookUrl":"91","executionMode":"92"},{"item":0},{"valid":true,"userId":1},{"item":0},{"item":0},{"used_tokens":"93","quota_tokens":"94","tokens_remaining":"95"},{"item":0},{"success":true,"used_tokens":14289,"quota_tokens":50000,"tokens_remaining":35711},{"item":0},{"item":0},{"host":"96","x-real-ip":"97","x-forwarded-for":"97","x-forwarded-proto":"98","connection":"99","sec-ch-ua-platform":"100","authorization":"101","user-agent":"102","accept":"103","sec-ch-ua":"104","dnt":"105","sec-ch-ua-mobile":"106","sec-fetch-site":"107","sec-fetch-mode":"108","sec-fetch-dest":"109","referer":"110","accept-encoding":"111","accept-language":"112","cookie":"113","sec-gpc":"105","if-none-match":"114"},{},{},{},"http://localhost:5678/webhook/wibot/user/tokens","production","14289","50000","35711","localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzAwODYsImV4cCI6MTc2Njg1NjQ4Nn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","W/\\"52-49lDe/j8Ze453oj3wcYlm3SsTGE\\""]
96	{"id":"msg5c740bd9db51","name":"WIBOT - Get Messages","active":true,"activeVersionId":"704bc444-e5e2-4901-9322-383bc1bd0434","isArchived":false,"createdAt":"2025-12-26T17:58:10.218Z","updatedAt":"2025-12-26T17:58:10.218Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/messages","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"webhook-messages","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,300],"webhookId":"wibot-messages"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst conversationId = $input.first().json.query.conversationId;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nif (!conversationId) {\\n  return [{ json: { valid: false, error: 'conversationId is required' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId, conversationId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"verify-jwt","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[470,300]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"if-jwt-valid","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[690,300]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-unauthorized","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[910,450]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  m.message_id,\\n  m.role,\\n  m.content,\\n  TO_CHAR(m.created_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as created_at\\nFROM messages m\\nJOIN conversations c ON m.conversation_id = c.conversation_id\\nWHERE m.conversation_id = '{{ $json.conversationId }}'::uuid\\n  AND c.user_id = {{ $json.userId }}\\nORDER BY m.created_at ASC;","options":{}},"id":"get-messages","name":"Get Messages","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[910,200],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats, retourner liste vide\\nif (!rows || rows.length === 0 || !rows[0].json.message_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      messages: []\\n    }\\n  }];\\n}\\n\\nconst messages = rows.map(row => ({\\n  message_id: row.json.message_id,\\n  role: row.json.role,\\n  content: row.json.content,\\n  created_at: row.json.created_at\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    messages\\n  }\\n}];","notice":""},"id":"format-response","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1130,200]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-success","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1350,200]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Messages","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Messages":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Messages":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766772148646,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766772148646,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766772148646,"executionIndex":1,"source":"29","hints":"30","executionTime":3,"executionStatus":"27","data":"31"},{"startTime":1766772148649,"executionIndex":2,"source":"32","hints":"33","executionTime":0,"executionStatus":"27","data":"34"},{"startTime":1766772148650,"executionIndex":3,"source":"35","hints":"36","executionTime":27,"executionStatus":"27","data":"37"},{"startTime":1766772148677,"executionIndex":4,"source":"38","hints":"39","executionTime":2,"executionStatus":"27","data":"40"},{"startTime":1766772148679,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75","76","77","78","79","80","81"],"Get Messages",["82"],"Format Response",["83"],{"json":"84","pairedItem":"85"},{"json":"86","pairedItem":"87"},{"json":"86","pairedItem":"88"},{"json":"89","pairedItem":"90"},{"json":"91","pairedItem":"90"},{"json":"92","pairedItem":"90"},{"json":"93","pairedItem":"90"},{"json":"94","pairedItem":"90"},{"json":"95","pairedItem":"90"},{"json":"96","pairedItem":"90"},{"json":"97","pairedItem":"90"},{"json":"98"},{"json":"98","pairedItem":"99"},{"headers":"100","params":"101","query":"102","body":"103","webhookUrl":"104","executionMode":"105"},{"item":0},{"valid":true,"userId":1,"conversationId":"106"},{"item":0},{"item":0},{"message_id":21,"role":"107","content":"108","created_at":"109"},{"item":0},{"message_id":22,"role":"110","content":"111","created_at":"109"},{"message_id":23,"role":"107","content":"112","created_at":"113"},{"message_id":24,"role":"110","content":"114","created_at":"113"},{"message_id":25,"role":"107","content":"112","created_at":"115"},{"message_id":26,"role":"110","content":"116","created_at":"115"},{"message_id":33,"role":"107","content":"117","created_at":"118"},{"message_id":34,"role":"110","content":"119","created_at":"118"},{"success":true,"messages":"120"},{"item":0},{"host":"121","x-real-ip":"122","x-forwarded-for":"122","x-forwarded-proto":"123","connection":"124","sec-ch-ua-platform":"125","authorization":"126","user-agent":"127","accept":"128","sec-ch-ua":"129","dnt":"130","sec-ch-ua-mobile":"131","sec-fetch-site":"132","sec-fetch-mode":"133","sec-fetch-dest":"134","referer":"135","accept-encoding":"136","accept-language":"137","cookie":"138","sec-gpc":"130"},{},{"conversationId":"106"},{},"http://localhost:5678/webhook/wibot/messages","production","963eb9f1-fdcc-4cd5-918b-29fae40c17a0","user","quel est le chiffre important que je t'ai donné ?","2025-12-26T16:45:37Z","assistant","Je n'ai pas de mémoire persistante entre nos interactions, donc je ne peux pas me souvenir des informations partagées lors de nos précédentes conversations. Si vous me donnez à nouveau le chiffre important, je serai ravi de vous aider avec celui-ci.\\n\\nN'hésitez pas à me le communiquer !","salut","2025-12-26T17:13:49Z","Salut ! Comment puis-je vous aider aujourd'hui ? 😊","2025-12-26T17:14:33Z","Bonjour ! Comment puis-je vous aider aujourd'hui ? 😊","dsf ça va ?","2025-12-26T17:34:13Z","Bonjour ! Je vais très bien, merci de demander. 😊\\n\\nComment puis-je vous aider aujourd'hui ?",["139","140","141","142","143","144","145","146"],"localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzAwODYsImV4cCI6MTc2Njg1NjQ4Nn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D",{"message_id":21,"role":"107","content":"108","created_at":"109"},{"message_id":22,"role":"110","content":"111","created_at":"109"},{"message_id":23,"role":"107","content":"112","created_at":"113"},{"message_id":24,"role":"110","content":"114","created_at":"113"},{"message_id":25,"role":"107","content":"112","created_at":"115"},{"message_id":26,"role":"110","content":"116","created_at":"115"},{"message_id":33,"role":"107","content":"117","created_at":"118"},{"message_id":34,"role":"110","content":"119","created_at":"118"}]
99	{"id":"msg5c740bd9db51","name":"WIBOT - Get Messages","active":true,"activeVersionId":"704bc444-e5e2-4901-9322-383bc1bd0434","isArchived":false,"createdAt":"2025-12-26T17:58:10.218Z","updatedAt":"2025-12-26T17:58:10.218Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/messages","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"webhook-messages","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,300],"webhookId":"wibot-messages"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst conversationId = $input.first().json.query.conversationId;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nif (!conversationId) {\\n  return [{ json: { valid: false, error: 'conversationId is required' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId, conversationId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"verify-jwt","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[470,300]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"if-jwt-valid","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[690,300]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-unauthorized","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[910,450]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  m.message_id,\\n  m.role,\\n  m.content,\\n  TO_CHAR(m.created_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as created_at\\nFROM messages m\\nJOIN conversations c ON m.conversation_id = c.conversation_id\\nWHERE m.conversation_id = '{{ $json.conversationId }}'::uuid\\n  AND c.user_id = {{ $json.userId }}\\nORDER BY m.created_at ASC;","options":{}},"id":"get-messages","name":"Get Messages","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[910,200],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats, retourner liste vide\\nif (!rows || rows.length === 0 || !rows[0].json.message_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      messages: []\\n    }\\n  }];\\n}\\n\\nconst messages = rows.map(row => ({\\n  message_id: row.json.message_id,\\n  role: row.json.role,\\n  content: row.json.content,\\n  created_at: row.json.created_at\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    messages\\n  }\\n}];","notice":""},"id":"format-response","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1130,200]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-success","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1350,200]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Messages","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Messages":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Messages":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766772150595,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766772150595,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766772150595,"executionIndex":1,"source":"29","hints":"30","executionTime":3,"executionStatus":"27","data":"31"},{"startTime":1766772150598,"executionIndex":2,"source":"32","hints":"33","executionTime":1,"executionStatus":"27","data":"34"},{"startTime":1766772150599,"executionIndex":3,"source":"35","hints":"36","executionTime":2,"executionStatus":"27","data":"37"},{"startTime":1766772150601,"executionIndex":4,"source":"38","hints":"39","executionTime":2,"executionStatus":"27","data":"40"},{"startTime":1766772150603,"executionIndex":5,"source":"41","hints":"42","executionTime":2,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75","76","77","78","79","80","81","82","83","84","85"],"Get Messages",["86"],"Format Response",["87"],{"json":"88","pairedItem":"89"},{"json":"90","pairedItem":"91"},{"json":"90","pairedItem":"92"},{"json":"93","pairedItem":"94"},{"json":"95","pairedItem":"94"},{"json":"96","pairedItem":"94"},{"json":"97","pairedItem":"94"},{"json":"98","pairedItem":"94"},{"json":"99","pairedItem":"94"},{"json":"100","pairedItem":"94"},{"json":"101","pairedItem":"94"},{"json":"102","pairedItem":"94"},{"json":"103","pairedItem":"94"},{"json":"104","pairedItem":"94"},{"json":"105","pairedItem":"94"},{"json":"106"},{"json":"106","pairedItem":"107"},{"headers":"108","params":"109","query":"110","body":"111","webhookUrl":"112","executionMode":"113"},{"item":0},{"valid":true,"userId":1,"conversationId":"114"},{"item":0},{"item":0},{"message_id":1,"role":"115","content":"116","created_at":"117"},{"item":0},{"message_id":2,"role":"118","content":"119","created_at":"120"},{"message_id":3,"role":"115","content":"121","created_at":"122"},{"message_id":4,"role":"118","content":"123","created_at":"124"},{"message_id":5,"role":"115","content":"125","created_at":"126"},{"message_id":6,"role":"118","content":"127","created_at":"128"},{"message_id":27,"role":"115","content":"129","created_at":"130"},{"message_id":28,"role":"118","content":"131","created_at":"130"},{"message_id":29,"role":"115","content":"132","created_at":"133"},{"message_id":30,"role":"118","content":"134","created_at":"133"},{"message_id":31,"role":"115","content":"135","created_at":"136"},{"message_id":32,"role":"118","content":"137","created_at":"136"},{"success":true,"messages":"138"},{"item":0},{"host":"139","x-real-ip":"140","x-forwarded-for":"140","x-forwarded-proto":"141","connection":"142","sec-ch-ua-platform":"143","authorization":"144","user-agent":"145","accept":"146","sec-ch-ua":"147","dnt":"148","sec-ch-ua-mobile":"149","sec-fetch-site":"150","sec-fetch-mode":"151","sec-fetch-dest":"152","referer":"153","accept-encoding":"154","accept-language":"155","cookie":"156","sec-gpc":"148"},{},{"conversationId":"114"},{},"http://localhost:5678/webhook/wibot/messages","production","550e8400-e29b-41d4-a716-446655440000","user","Bonjour WIBOT !","2025-12-24T07:42:15Z","assistant","Bonjour ! Je suis WIBOT, l'assistant IA de WIDIP. Comment puis-je t'aider aujourd'hui ?","2025-12-24T07:42:17Z","Peux-tu m'expliquer comment fonctionne PostgreSQL ?","2025-12-24T07:43:15Z","PostgreSQL est un systeme de gestion de base de donnees relationnelle (SGBDR) open source tres puissant.\\n\\n**Caracteristiques principales :**\\n- Support complet SQL\\n- Transactions ACID\\n- Extensions (comme pgcrypto pour le chiffrement)\\n- Excellent pour les charges de travail complexes\\n\\nC'est ce qu'on utilise chez WIDIP pour stocker les donnees WIBOT !","2025-12-24T07:43:20Z","Et comment faire un backup ?","2025-12-25T07:42:15Z","Pour faire un backup PostgreSQL, tu as plusieurs options :\\n\\n```bash\\n# Backup complet (dump SQL)\\npg_dump -U widip -d wibot > backup.sql\\n\\n# Backup compresse\\npg_dump -U widip -d wibot | gzip > backup.sql.gz\\n\\n# Restauration\\npsql -U widip -d wibot < backup.sql\\n```\\n\\nPour les backups automatiques, on peut utiliser un cron job ou un workflow n8n !","2025-12-25T07:42:18Z","salut","2025-12-26T17:16:30Z","Salut ! Comment puis-je vous aider aujourd'hui ?","ddadzax","2025-12-26T17:16:38Z","Bonjour ! Je ne suis pas sûr de comprendre votre demande. Pourriez-vous préciser ou reformuler votre question ? Je suis là pour vous aider avec les questions techniques ou toute autre demande liée à WIDIP.","hey","2025-12-26T17:28:13Z","Bonjour ! Comment puis-je vous aider aujourd'hui ?",["157","158","159","160","161","162","163","164","165","166","167","168"],"localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzAwODYsImV4cCI6MTc2Njg1NjQ4Nn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D",{"message_id":1,"role":"115","content":"116","created_at":"117"},{"message_id":2,"role":"118","content":"119","created_at":"120"},{"message_id":3,"role":"115","content":"121","created_at":"122"},{"message_id":4,"role":"118","content":"123","created_at":"124"},{"message_id":5,"role":"115","content":"125","created_at":"126"},{"message_id":6,"role":"118","content":"127","created_at":"128"},{"message_id":27,"role":"115","content":"129","created_at":"130"},{"message_id":28,"role":"118","content":"131","created_at":"130"},{"message_id":29,"role":"115","content":"132","created_at":"133"},{"message_id":30,"role":"118","content":"134","created_at":"133"},{"message_id":31,"role":"115","content":"135","created_at":"136"},{"message_id":32,"role":"118","content":"137","created_at":"136"}]
91	{"id":"yPYTzGXVRP2JQxs8","name":"WIBOT - Get Conversations","active":true,"activeVersionId":"e1bae720-4a31-4afe-a595-4a35f7e26b0f","isArchived":false,"createdAt":"2025-12-26T17:23:46.197Z","updatedAt":"2025-12-26T17:24:07.735Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/conversations","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"c0f9fbaf-d0bb-4e86-92e9-c3e34e750679","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-656,112],"webhookId":"wibot-conversations"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"a5bd8ac1-82cc-4021-8420-752f46440f49","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"352ea961-e9a7-4651-acad-b594ba9f1c8c","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"9a0fd5d7-2e41-4111-b2b2-f84c1403ea28","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  c.conversation_id::text,\\n  c.title,\\n  TO_CHAR(c.updated_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as updated_at,\\n  COUNT(m.message_id)::integer as message_count\\nFROM conversations c\\nLEFT JOIN messages m ON c.conversation_id = m.conversation_id\\nWHERE c.user_id = {{ $json.userId }}\\nGROUP BY c.conversation_id, c.title, c.updated_at\\nORDER BY c.updated_at DESC\\nLIMIT 50;","options":{}},"id":"8fe150d4-0f4e-41ac-bd90-8978f31f4459","name":"Get Conversations","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[0,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats ou resultats vides\\nif (!rows || rows.length === 0 || !rows[0].json.conversation_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      conversations: []\\n    }\\n  }];\\n}\\n\\nconst conversations = rows.map(row => ({\\n  conversation_id: row.json.conversation_id,\\n  title: row.json.title || 'Nouvelle conversation',\\n  updated_at: row.json.updated_at,\\n  message_count: parseInt(row.json.message_count) || 0\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    conversations\\n  }\\n}];","notice":""},"id":"8d9137c5-9aa8-4938-961f-50bdbc93ee8f","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"463fcf83-1d8e-472a-94df-623b505f1a5d","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[448,0]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Conversations","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Conversations":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Conversations":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766772111365,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766772111366,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766772111366,"executionIndex":1,"source":"29","hints":"30","executionTime":4,"executionStatus":"27","data":"31"},{"startTime":1766772111370,"executionIndex":2,"source":"32","hints":"33","executionTime":1,"executionStatus":"27","data":"34"},{"startTime":1766772111371,"executionIndex":3,"source":"35","hints":"36","executionTime":3,"executionStatus":"27","data":"37"},{"startTime":1766772111374,"executionIndex":4,"source":"38","hints":"39","executionTime":3,"executionStatus":"27","data":"40"},{"startTime":1766772111377,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75","76"],"Get Conversations",["77"],"Format Response",["78"],{"json":"79","pairedItem":"80"},{"json":"81","pairedItem":"82"},{"json":"81","pairedItem":"83"},{"json":"84","pairedItem":"85"},{"json":"86","pairedItem":"85"},{"json":"87","pairedItem":"85"},{"json":"88"},{"json":"88","pairedItem":"89"},{"headers":"90","params":"91","query":"92","body":"93","webhookUrl":"94","executionMode":"95"},{"item":0},{"valid":true,"userId":1},{"item":0},{"item":0},{"conversation_id":"96","title":"97","updated_at":"98","message_count":8},{"item":0},{"conversation_id":"99","title":"100","updated_at":"101","message_count":12},{"conversation_id":"102","title":"103","updated_at":"104","message_count":14},{"success":true,"conversations":"105"},{"item":0},{"host":"106","x-real-ip":"107","x-forwarded-for":"107","x-forwarded-proto":"108","connection":"109","user-agent":"110","accept":"111","authorization":"112"},{},{},{},"http://localhost:5678/webhook/wibot/conversations","production","963eb9f1-fdcc-4cd5-918b-29fae40c17a0","quel est le chiffre important que je t'ai donné ?","2025-12-26T17:34:13Z","550e8400-e29b-41d4-a716-446655440000","Conversation de test","2025-12-26T17:28:13Z","3cc2c8db-afef-4637-accc-31d259f53857","saluty","2025-12-26T16:45:24Z",["113","114","115"],"localhost","172.20.0.1","http","close","curl/8.12.1","*/*","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzIwODgsImV4cCI6MTc2Njg1ODQ4OH0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh",{"conversation_id":"96","title":"97","updated_at":"98","message_count":8},{"conversation_id":"99","title":"100","updated_at":"101","message_count":12},{"conversation_id":"102","title":"103","updated_at":"104","message_count":14}]
95	{"id":"yPYTzGXVRP2JQxs8","name":"WIBOT - Get Conversations","active":true,"activeVersionId":"e1bae720-4a31-4afe-a595-4a35f7e26b0f","isArchived":false,"createdAt":"2025-12-26T17:23:46.197Z","updatedAt":"2025-12-26T17:24:07.735Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/conversations","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"c0f9fbaf-d0bb-4e86-92e9-c3e34e750679","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-656,112],"webhookId":"wibot-conversations"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"a5bd8ac1-82cc-4021-8420-752f46440f49","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"352ea961-e9a7-4651-acad-b594ba9f1c8c","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"9a0fd5d7-2e41-4111-b2b2-f84c1403ea28","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  c.conversation_id::text,\\n  c.title,\\n  TO_CHAR(c.updated_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as updated_at,\\n  COUNT(m.message_id)::integer as message_count\\nFROM conversations c\\nLEFT JOIN messages m ON c.conversation_id = m.conversation_id\\nWHERE c.user_id = {{ $json.userId }}\\nGROUP BY c.conversation_id, c.title, c.updated_at\\nORDER BY c.updated_at DESC\\nLIMIT 50;","options":{}},"id":"8fe150d4-0f4e-41ac-bd90-8978f31f4459","name":"Get Conversations","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[0,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats ou resultats vides\\nif (!rows || rows.length === 0 || !rows[0].json.conversation_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      conversations: []\\n    }\\n  }];\\n}\\n\\nconst conversations = rows.map(row => ({\\n  conversation_id: row.json.conversation_id,\\n  title: row.json.title || 'Nouvelle conversation',\\n  updated_at: row.json.updated_at,\\n  message_count: parseInt(row.json.message_count) || 0\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    conversations\\n  }\\n}];","notice":""},"id":"8d9137c5-9aa8-4938-961f-50bdbc93ee8f","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"463fcf83-1d8e-472a-94df-623b505f1a5d","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[448,0]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Conversations","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Conversations":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Conversations":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766772148641,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766772148642,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766772148642,"executionIndex":1,"source":"29","hints":"30","executionTime":2,"executionStatus":"27","data":"31"},{"startTime":1766772148644,"executionIndex":2,"source":"32","hints":"33","executionTime":1,"executionStatus":"27","data":"34"},{"startTime":1766772148645,"executionIndex":3,"source":"35","hints":"36","executionTime":8,"executionStatus":"27","data":"37"},{"startTime":1766772148653,"executionIndex":4,"source":"38","hints":"39","executionTime":3,"executionStatus":"27","data":"40"},{"startTime":1766772148656,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75","76"],"Get Conversations",["77"],"Format Response",["78"],{"json":"79","pairedItem":"80"},{"json":"81","pairedItem":"82"},{"json":"81","pairedItem":"83"},{"json":"84","pairedItem":"85"},{"json":"86","pairedItem":"85"},{"json":"87","pairedItem":"85"},{"json":"88"},{"json":"88","pairedItem":"89"},{"headers":"90","params":"91","query":"92","body":"93","webhookUrl":"94","executionMode":"95"},{"item":0},{"valid":true,"userId":1},{"item":0},{"item":0},{"conversation_id":"96","title":"97","updated_at":"98","message_count":8},{"item":0},{"conversation_id":"99","title":"100","updated_at":"101","message_count":12},{"conversation_id":"102","title":"103","updated_at":"104","message_count":14},{"success":true,"conversations":"105"},{"item":0},{"host":"106","x-real-ip":"107","x-forwarded-for":"107","x-forwarded-proto":"108","connection":"109","sec-ch-ua-platform":"110","authorization":"111","user-agent":"112","accept":"113","sec-ch-ua":"114","dnt":"115","sec-ch-ua-mobile":"116","sec-fetch-site":"117","sec-fetch-mode":"118","sec-fetch-dest":"119","referer":"120","accept-encoding":"121","accept-language":"122","cookie":"123","sec-gpc":"115","if-none-match":"124"},{},{},{},"http://localhost:5678/webhook/wibot/conversations","production","963eb9f1-fdcc-4cd5-918b-29fae40c17a0","quel est le chiffre important que je t'ai donné ?","2025-12-26T17:34:13Z","550e8400-e29b-41d4-a716-446655440000","Conversation de test","2025-12-26T17:28:13Z","3cc2c8db-afef-4637-accc-31d259f53857","saluty","2025-12-26T16:45:24Z",["125","126","127"],"localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzAwODYsImV4cCI6MTc2Njg1NjQ4Nn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","W/\\"1e4-oCAPe6gog56nbHcwBhya3J1Oeb8\\"",{"conversation_id":"96","title":"97","updated_at":"98","message_count":8},{"conversation_id":"99","title":"100","updated_at":"101","message_count":12},{"conversation_id":"102","title":"103","updated_at":"104","message_count":14}]
97	{"id":"c8fbjjX9ObuzBE4b","name":"WIBOT - Get User Tokens","active":true,"activeVersionId":"62643582-5e10-4f85-9c6c-74a85d102e67","isArchived":false,"createdAt":"2025-12-26T17:24:01.471Z","updatedAt":"2025-12-26T17:24:05.529Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/user/tokens","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"8fcee23f-b3e4-4c28-ad04-4ba456f7752a","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-656,112],"webhookId":"wibot-user-tokens"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"d8de2cd5-94e4-49a5-a318-1ee1c389abd9","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"c9c309e4-53ba-46be-8960-13da82f4f5f7","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"83cd3ac8-fb46-4de5-a8ce-5d24be08334c","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  COALESCE(used_tokens, 0) as used_tokens,\\n  COALESCE(quota_tokens, 50000) as quota_tokens,\\n  COALESCE(quota_tokens, 50000) - COALESCE(used_tokens, 0) as tokens_remaining\\nFROM user_token_usage\\nWHERE user_id = {{ $json.userId }}\\n  AND month = DATE_TRUNC('month', CURRENT_DATE)\\nLIMIT 1;","options":{}},"id":"b35fa964-24c4-49ed-a3b6-7df917662ceb","name":"Get Token Usage","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[0,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\nconst jwtData = $('Verify JWT').first().json;\\n\\n// Si pas de donnees, l'utilisateur n'a pas encore utilise de tokens ce mois\\nif (!rows || rows.length === 0 || rows[0].json.tokens_remaining === undefined) {\\n  return [{\\n    json: {\\n      success: true,\\n      used_tokens: 0,\\n      quota_tokens: 50000,\\n      tokens_remaining: 50000\\n    }\\n  }];\\n}\\n\\nconst data = rows[0].json;\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    used_tokens: parseInt(data.used_tokens) || 0,\\n    quota_tokens: parseInt(data.quota_tokens) || 50000,\\n    tokens_remaining: parseInt(data.tokens_remaining) || 50000\\n  }\\n}];","notice":""},"id":"7d9b1764-6fed-49d3-957f-402aa7f05696","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"67daad4e-a2fe-4b36-b18c-065181b80de3","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[448,0]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Token Usage","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Token Usage":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Token Usage":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766772148659,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766772148659,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766772148659,"executionIndex":1,"source":"29","hints":"30","executionTime":3,"executionStatus":"27","data":"31"},{"startTime":1766772148662,"executionIndex":2,"source":"32","hints":"33","executionTime":1,"executionStatus":"27","data":"34"},{"startTime":1766772148663,"executionIndex":3,"source":"35","hints":"36","executionTime":3,"executionStatus":"27","data":"37"},{"startTime":1766772148666,"executionIndex":4,"source":"38","hints":"39","executionTime":2,"executionStatus":"27","data":"40"},{"startTime":1766772148669,"executionIndex":5,"source":"41","hints":"42","executionTime":0,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74"],"Get Token Usage",["75"],"Format Response",["76"],{"json":"77","pairedItem":"78"},{"json":"79","pairedItem":"80"},{"json":"79","pairedItem":"81"},{"json":"82","pairedItem":"83"},{"json":"84","pairedItem":"85"},{"json":"84","pairedItem":"86"},{"headers":"87","params":"88","query":"89","body":"90","webhookUrl":"91","executionMode":"92"},{"item":0},{"valid":true,"userId":1},{"item":0},{"item":0},{"used_tokens":"93","quota_tokens":"94","tokens_remaining":"95"},{"item":0},{"success":true,"used_tokens":14289,"quota_tokens":50000,"tokens_remaining":35711},{"item":0},{"item":0},{"host":"96","x-real-ip":"97","x-forwarded-for":"97","x-forwarded-proto":"98","connection":"99","sec-ch-ua-platform":"100","authorization":"101","user-agent":"102","accept":"103","sec-ch-ua":"104","dnt":"105","sec-ch-ua-mobile":"106","sec-fetch-site":"107","sec-fetch-mode":"108","sec-fetch-dest":"109","referer":"110","accept-encoding":"111","accept-language":"112","cookie":"113","sec-gpc":"105","if-none-match":"114"},{},{},{},"http://localhost:5678/webhook/wibot/user/tokens","production","14289","50000","35711","localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzAwODYsImV4cCI6MTc2Njg1NjQ4Nn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","W/\\"52-bzbXh/RvEQA2yaKK8CkF6t5J3wM\\""]
98	{"id":"msg5c740bd9db51","name":"WIBOT - Get Messages","active":true,"activeVersionId":"704bc444-e5e2-4901-9322-383bc1bd0434","isArchived":false,"createdAt":"2025-12-26T17:58:10.218Z","updatedAt":"2025-12-26T17:58:10.218Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/messages","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"webhook-messages","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,300],"webhookId":"wibot-messages"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst conversationId = $input.first().json.query.conversationId;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nif (!conversationId) {\\n  return [{ json: { valid: false, error: 'conversationId is required' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId, conversationId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"verify-jwt","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[470,300]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"if-jwt-valid","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[690,300]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-unauthorized","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[910,450]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  m.message_id,\\n  m.role,\\n  m.content,\\n  TO_CHAR(m.created_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as created_at\\nFROM messages m\\nJOIN conversations c ON m.conversation_id = c.conversation_id\\nWHERE m.conversation_id = '{{ $json.conversationId }}'::uuid\\n  AND c.user_id = {{ $json.userId }}\\nORDER BY m.created_at ASC;","options":{}},"id":"get-messages","name":"Get Messages","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[910,200],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats, retourner liste vide\\nif (!rows || rows.length === 0 || !rows[0].json.message_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      messages: []\\n    }\\n  }];\\n}\\n\\nconst messages = rows.map(row => ({\\n  message_id: row.json.message_id,\\n  role: row.json.role,\\n  content: row.json.content,\\n  created_at: row.json.created_at\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    messages\\n  }\\n}];","notice":""},"id":"format-response","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1130,200]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-success","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1350,200]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Messages","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Messages":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Messages":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766772148704,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766772148704,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766772148705,"executionIndex":1,"source":"29","hints":"30","executionTime":3,"executionStatus":"27","data":"31"},{"startTime":1766772148708,"executionIndex":2,"source":"32","hints":"33","executionTime":0,"executionStatus":"27","data":"34"},{"startTime":1766772148709,"executionIndex":3,"source":"35","hints":"36","executionTime":2,"executionStatus":"27","data":"37"},{"startTime":1766772148711,"executionIndex":4,"source":"38","hints":"39","executionTime":3,"executionStatus":"27","data":"40"},{"startTime":1766772148714,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75","76","77","78","79","80","81"],"Get Messages",["82"],"Format Response",["83"],{"json":"84","pairedItem":"85"},{"json":"86","pairedItem":"87"},{"json":"86","pairedItem":"88"},{"json":"89","pairedItem":"90"},{"json":"91","pairedItem":"90"},{"json":"92","pairedItem":"90"},{"json":"93","pairedItem":"90"},{"json":"94","pairedItem":"90"},{"json":"95","pairedItem":"90"},{"json":"96","pairedItem":"90"},{"json":"97","pairedItem":"90"},{"json":"98"},{"json":"98","pairedItem":"99"},{"headers":"100","params":"101","query":"102","body":"103","webhookUrl":"104","executionMode":"105"},{"item":0},{"valid":true,"userId":1,"conversationId":"106"},{"item":0},{"item":0},{"message_id":21,"role":"107","content":"108","created_at":"109"},{"item":0},{"message_id":22,"role":"110","content":"111","created_at":"109"},{"message_id":23,"role":"107","content":"112","created_at":"113"},{"message_id":24,"role":"110","content":"114","created_at":"113"},{"message_id":25,"role":"107","content":"112","created_at":"115"},{"message_id":26,"role":"110","content":"116","created_at":"115"},{"message_id":33,"role":"107","content":"117","created_at":"118"},{"message_id":34,"role":"110","content":"119","created_at":"118"},{"success":true,"messages":"120"},{"item":0},{"host":"121","x-real-ip":"122","x-forwarded-for":"122","x-forwarded-proto":"123","connection":"124","sec-ch-ua-platform":"125","authorization":"126","user-agent":"127","accept":"128","sec-ch-ua":"129","dnt":"130","sec-ch-ua-mobile":"131","sec-fetch-site":"132","sec-fetch-mode":"133","sec-fetch-dest":"134","referer":"135","accept-encoding":"136","accept-language":"137","cookie":"138","sec-gpc":"130","if-none-match":"139"},{},{"conversationId":"106"},{},"http://localhost:5678/webhook/wibot/messages","production","963eb9f1-fdcc-4cd5-918b-29fae40c17a0","user","quel est le chiffre important que je t'ai donné ?","2025-12-26T16:45:37Z","assistant","Je n'ai pas de mémoire persistante entre nos interactions, donc je ne peux pas me souvenir des informations partagées lors de nos précédentes conversations. Si vous me donnez à nouveau le chiffre important, je serai ravi de vous aider avec celui-ci.\\n\\nN'hésitez pas à me le communiquer !","salut","2025-12-26T17:13:49Z","Salut ! Comment puis-je vous aider aujourd'hui ? 😊","2025-12-26T17:14:33Z","Bonjour ! Comment puis-je vous aider aujourd'hui ? 😊","dsf ça va ?","2025-12-26T17:34:13Z","Bonjour ! Je vais très bien, merci de demander. 😊\\n\\nComment puis-je vous aider aujourd'hui ?",["140","141","142","143","144","145","146","147"],"localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzAwODYsImV4cCI6MTc2Njg1NjQ4Nn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","W/\\"4f5-iX7OrMLhqWRZ+Pgvd44GsjyMq3A\\"",{"message_id":21,"role":"107","content":"108","created_at":"109"},{"message_id":22,"role":"110","content":"111","created_at":"109"},{"message_id":23,"role":"107","content":"112","created_at":"113"},{"message_id":24,"role":"110","content":"114","created_at":"113"},{"message_id":25,"role":"107","content":"112","created_at":"115"},{"message_id":26,"role":"110","content":"116","created_at":"115"},{"message_id":33,"role":"107","content":"117","created_at":"118"},{"message_id":34,"role":"110","content":"119","created_at":"118"}]
100	{"id":"msg5c740bd9db51","name":"WIBOT - Get Messages","active":true,"activeVersionId":"704bc444-e5e2-4901-9322-383bc1bd0434","isArchived":false,"createdAt":"2025-12-26T17:58:10.218Z","updatedAt":"2025-12-26T17:58:10.218Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/messages","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"webhook-messages","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,300],"webhookId":"wibot-messages"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst conversationId = $input.first().json.query.conversationId;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nif (!conversationId) {\\n  return [{ json: { valid: false, error: 'conversationId is required' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId, conversationId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"verify-jwt","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[470,300]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"if-jwt-valid","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[690,300]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-unauthorized","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[910,450]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  m.message_id,\\n  m.role,\\n  m.content,\\n  TO_CHAR(m.created_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as created_at\\nFROM messages m\\nJOIN conversations c ON m.conversation_id = c.conversation_id\\nWHERE m.conversation_id = '{{ $json.conversationId }}'::uuid\\n  AND c.user_id = {{ $json.userId }}\\nORDER BY m.created_at ASC;","options":{}},"id":"get-messages","name":"Get Messages","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[910,200],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats, retourner liste vide\\nif (!rows || rows.length === 0 || !rows[0].json.message_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      messages: []\\n    }\\n  }];\\n}\\n\\nconst messages = rows.map(row => ({\\n  message_id: row.json.message_id,\\n  role: row.json.role,\\n  content: row.json.content,\\n  created_at: row.json.created_at\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    messages\\n  }\\n}];","notice":""},"id":"format-response","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1130,200]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-success","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1350,200]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Messages","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Messages":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Messages":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766772151527,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766772151527,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766772151528,"executionIndex":1,"source":"29","hints":"30","executionTime":3,"executionStatus":"27","data":"31"},{"startTime":1766772151531,"executionIndex":2,"source":"32","hints":"33","executionTime":1,"executionStatus":"27","data":"34"},{"startTime":1766772151532,"executionIndex":3,"source":"35","hints":"36","executionTime":3,"executionStatus":"27","data":"37"},{"startTime":1766772151535,"executionIndex":4,"source":"38","hints":"39","executionTime":2,"executionStatus":"27","data":"40"},{"startTime":1766772151538,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75","76","77","78","79","80","81","82","83","84","85","86","87"],"Get Messages",["88"],"Format Response",["89"],{"json":"90","pairedItem":"91"},{"json":"92","pairedItem":"93"},{"json":"92","pairedItem":"94"},{"json":"95","pairedItem":"96"},{"json":"97","pairedItem":"96"},{"json":"98","pairedItem":"96"},{"json":"99","pairedItem":"96"},{"json":"100","pairedItem":"96"},{"json":"101","pairedItem":"96"},{"json":"102","pairedItem":"96"},{"json":"103","pairedItem":"96"},{"json":"104","pairedItem":"96"},{"json":"105","pairedItem":"96"},{"json":"106","pairedItem":"96"},{"json":"107","pairedItem":"96"},{"json":"108","pairedItem":"96"},{"json":"109","pairedItem":"96"},{"json":"110"},{"json":"110","pairedItem":"111"},{"headers":"112","params":"113","query":"114","body":"115","webhookUrl":"116","executionMode":"117"},{"item":0},{"valid":true,"userId":1,"conversationId":"118"},{"item":0},{"item":0},{"message_id":7,"role":"119","content":"120","created_at":"121"},{"item":0},{"message_id":8,"role":"122","content":"123","created_at":"121"},{"message_id":9,"role":"119","content":"124","created_at":"125"},{"message_id":10,"role":"122","content":"126","created_at":"125"},{"message_id":11,"role":"119","content":"127","created_at":"128"},{"message_id":12,"role":"122","content":"129","created_at":"128"},{"message_id":13,"role":"119","content":"130","created_at":"131"},{"message_id":14,"role":"122","content":"132","created_at":"131"},{"message_id":15,"role":"119","content":"133","created_at":"134"},{"message_id":16,"role":"122","content":"135","created_at":"134"},{"message_id":17,"role":"119","content":"136","created_at":"137"},{"message_id":18,"role":"122","content":"138","created_at":"137"},{"message_id":19,"role":"119","content":"139","created_at":"140"},{"message_id":20,"role":"122","content":"141","created_at":"140"},{"success":true,"messages":"142"},{"item":0},{"host":"143","x-real-ip":"144","x-forwarded-for":"144","x-forwarded-proto":"145","connection":"146","sec-ch-ua-platform":"147","authorization":"148","user-agent":"149","accept":"150","sec-ch-ua":"151","dnt":"152","sec-ch-ua-mobile":"153","sec-fetch-site":"154","sec-fetch-mode":"155","sec-fetch-dest":"156","referer":"157","accept-encoding":"158","accept-language":"159","cookie":"160","sec-gpc":"152"},{},{"conversationId":"118"},{},"http://localhost:5678/webhook/wibot/messages","production","3cc2c8db-afef-4637-accc-31d259f53857","user","saluty","2025-12-26T16:43:14Z","assistant","Bonjour ! Comment puis-je vous aider aujourd'hui ?","tout va bien ?","2025-12-26T16:43:24Z","Tout va très bien, merci de demander ! Je suis prêt à vous aider avec vos questions techniques. Comment puis-je vous assister aujourd'hui ?","genere un max de text je test la conso token","2025-12-26T16:43:40Z","Je comprends que vous souhaitez tester la consommation de tokens. Voici un texte plus long pour vous aider dans votre test :\\n\\n---\\n\\nChez WIDIP, nous sommes une entreprise française de services informatiques spécialisée dans l'accompagnement des entreprises dans leur transformation numérique. Notre mission est de fournir des solutions technologiques innovantes et sur mesure pour répondre aux besoins spécifiques de nos clients.\\n\\nNous offrons une large gamme de services, allant du développement de logiciels sur mesure à l'infogérance, en passant par la cybersécurité et le cloud computing. Notre équipe d'experts est composée de professionnels qualifiés et passionnés, toujours prêts à relever les défis technologiques les plus complexes.\\n\\nChez WIDIP, nous croyons en l'importance de la collaboration et de la communication. Nous travaillons en étroite collaboration avec nos clients pour comprendre leurs besoins et leurs attentes, et nous nous engageons à fournir des solutions qui non seulement répondent à ces besoins, mais qui les dépassent.\\n\\nNous sommes également convaincus que la formation et le développement des compétences sont essentiels pour rester à la pointe de la technologie. C'est pourquoi nous investissons continuellement dans la formation de nos employés et dans l'acquisition de nouvelles compétences.\\n\\nEn choisissant WIDIP, vous bénéficiez de notre expertise, de notre engagement et de notre passion pour la technologie. Nous sommes là pour vous accompagner à chaque étape de votre transformation numérique, en vous fournissant des solutions qui vous permettent de tirer le meilleur parti de la technologie.\\n\\nSi vous avez des questions ou si vous souhaitez en savoir plus sur nos services, n'hésitez pas à nous contacter. Nous serons ravis de vous aider.\\n\\n---\\n\\nJ'espère que ce texte répond à vos besoins pour le test de consommation de tokens. Si vous avez d'autres questions ou besoin de plus d'informations, n'hésitez pas à me le faire savoir !","encore","2025-12-26T16:43:51Z","Bien sûr ! Voici un texte encore plus long pour votre test de consommation de tokens :\\n\\n---\\n\\nChez WIDIP, nous sommes une entreprise française de services informatiques spécialisée dans l'accompagnement des entreprises dans leur transformation numérique. Notre mission est de fournir des solutions technologiques innovantes et sur mesure pour répondre aux besoins spécifiques de nos clients.\\n\\nNous offrons une large gamme de services, allant du développement de logiciels sur mesure à l'infogérance, en passant par la cybersécurité et le cloud computing. Notre équipe d'experts est composée de professionnels qualifiés et passionnés, toujours prêts à relever les défis technologiques les plus complexes.\\n\\nChez WIDIP, nous croyons en l'importance de la collaboration et de la communication. Nous travaillons en étroite collaboration avec nos clients pour comprendre leurs besoins et leurs attentes, et nous nous engageons à fournir des solutions qui non seulement répondent à ces besoins, mais qui les dépassent.\\n\\nNous sommes également convaincus que la formation et le développement des compétences sont essentiels pour rester à la pointe de la technologie. C'est pourquoi nous investissons continuellement dans la formation de nos employés et dans l'acquisition de nouvelles compétences.\\n\\nEn choisissant WIDIP, vous bénéficiez de notre expertise, de notre engagement et de notre passion pour la technologie. Nous sommes là pour vous accompagner à chaque étape de votre transformation numérique, en vous fournissant des solutions qui vous permettent de tirer le meilleur parti de la technologie.\\n\\nSi vous avez des questions ou si vous souhaitez en savoir plus sur nos services, n'hésitez pas à nous contacter. Nous serons ravis de vous aider.\\n\\n---\\n\\nVoici un exemple de code en Python pour illustrer nos compétences en développement de logiciels :\\n\\n```python\\n# Exemple de code Python pour calculer la factorielle d'un nombre\\n\\ndef factorielle(n):\\n    if n == 0:\\n        return 1\\n    else:\\n        return n * factorielle(n - 1)\\n\\n# Exemple d'utilisation\\nnombre = 5\\nresultat = factorielle(nombre)\\nprint(f\\"La factorielle de {nombre} est {resultat}\\")\\n```\\n\\nChez WIDIP, nous utilisons des technologies de pointe pour développer des solutions robustes et évolutives. Nos développeurs sont expérimentés dans divers langages de programmation, tels que Python, Java, C++, et bien d'autres.\\n\\nNous mettons également un point d'honneur à suivre les meilleures pratiques en matière de développement logiciel, telles que la programmation orientée objet, les tests unitaires, et la documentation du code. Nous croyons que ces pratiques sont essentielles pour garantir la qualité et la maintenabilité de nos solutions.\\n\\nEn plus du développement de logiciels, nous offrons également des services d'infogérance pour aider nos clients à gérer leurs infrastructures informatiques. Nos experts en infogérance peuvent vous aider à optimiser vos systèmes, à améliorer leur sécurité, et à assurer leur disponibilité.\\n\\nNous proposons également des services de cybersécurité pour protéger vos données et vos systèmes contre les cybermenaces. Nos experts en cybersécurité peuvent vous aider à mettre en place des mesures de sécurité efficaces, à effectuer des audits de sécurité, et à répondre aux incidents de sécurité.\\n\\nEnfin, nous offrons des services de cloud computing pour vous aider à tirer parti des avantages du cloud. Nos experts en cloud computing peuvent vous aider à migrer vers le cloud, à optimiser vos coûts, et à tirer parti des fonctionnalités avancées des plateformes cloud.\\n\\nSi vous avez des questions ou si vous souhaitez en savoir plus sur nos services, n'hésitez pas à nous contacter. Nous serons ravis de vous aider.\\n\\n---\\n\\nJ'espère que ce texte supplémentaire répond à vos besoins pour le test de consommation de tokens. Si vous avez d'autres questions ou besoin de plus d'informations, n'hésitez pas à me le faire savoir !","hey !","2025-12-26T16:44:56Z","Bonjour ! Comment puis-je vous aider aujourd'hui ? 😊","je vais te donner un chiffre important tu vas le retenir , tu es pret ?","2025-12-26T16:45:18Z","Je suis prêt ! Donnez-moi le chiffre important, et je le retiendrai pour vous.","1996","2025-12-26T16:45:24Z","J'ai retenu le chiffre **1996**. Comment puis-je vous aider avec cette information ?",["161","162","163","164","165","166","167","168","169","170","171","172","173","174"],"localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzAwODYsImV4cCI6MTc2Njg1NjQ4Nn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D",{"message_id":7,"role":"119","content":"120","created_at":"121"},{"message_id":8,"role":"122","content":"123","created_at":"121"},{"message_id":9,"role":"119","content":"124","created_at":"125"},{"message_id":10,"role":"122","content":"126","created_at":"125"},{"message_id":11,"role":"119","content":"127","created_at":"128"},{"message_id":12,"role":"122","content":"129","created_at":"128"},{"message_id":13,"role":"119","content":"130","created_at":"131"},{"message_id":14,"role":"122","content":"132","created_at":"131"},{"message_id":15,"role":"119","content":"133","created_at":"134"},{"message_id":16,"role":"122","content":"135","created_at":"134"},{"message_id":17,"role":"119","content":"136","created_at":"137"},{"message_id":18,"role":"122","content":"138","created_at":"137"},{"message_id":19,"role":"119","content":"139","created_at":"140"},{"message_id":20,"role":"122","content":"141","created_at":"140"}]
102	{"id":"msg5c740bd9db51","name":"WIBOT - Get Messages","active":true,"activeVersionId":"704bc444-e5e2-4901-9322-383bc1bd0434","isArchived":false,"createdAt":"2025-12-26T17:58:10.218Z","updatedAt":"2025-12-26T17:58:10.218Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/messages","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"webhook-messages","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,300],"webhookId":"wibot-messages"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst conversationId = $input.first().json.query.conversationId;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nif (!conversationId) {\\n  return [{ json: { valid: false, error: 'conversationId is required' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId, conversationId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"verify-jwt","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[470,300]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"if-jwt-valid","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[690,300]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-unauthorized","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[910,450]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  m.message_id,\\n  m.role,\\n  m.content,\\n  TO_CHAR(m.created_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as created_at\\nFROM messages m\\nJOIN conversations c ON m.conversation_id = c.conversation_id\\nWHERE m.conversation_id = '{{ $json.conversationId }}'::uuid\\n  AND c.user_id = {{ $json.userId }}\\nORDER BY m.created_at ASC;","options":{}},"id":"get-messages","name":"Get Messages","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[910,200],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats, retourner liste vide\\nif (!rows || rows.length === 0 || !rows[0].json.message_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      messages: []\\n    }\\n  }];\\n}\\n\\nconst messages = rows.map(row => ({\\n  message_id: row.json.message_id,\\n  role: row.json.role,\\n  content: row.json.content,\\n  created_at: row.json.created_at\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    messages\\n  }\\n}];","notice":""},"id":"format-response","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1130,200]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-success","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1350,200]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Messages","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Messages":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Messages":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766772157366,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766772157366,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766772157366,"executionIndex":1,"source":"29","hints":"30","executionTime":2,"executionStatus":"27","data":"31"},{"startTime":1766772157368,"executionIndex":2,"source":"32","hints":"33","executionTime":1,"executionStatus":"27","data":"34"},{"startTime":1766772157369,"executionIndex":3,"source":"35","hints":"36","executionTime":2,"executionStatus":"27","data":"37"},{"startTime":1766772157371,"executionIndex":4,"source":"38","hints":"39","executionTime":2,"executionStatus":"27","data":"40"},{"startTime":1766772157373,"executionIndex":5,"source":"41","hints":"42","executionTime":0,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75","76","77","78","79","80","81","82","83","84","85"],"Get Messages",["86"],"Format Response",["87"],{"json":"88","pairedItem":"89"},{"json":"90","pairedItem":"91"},{"json":"90","pairedItem":"92"},{"json":"93","pairedItem":"94"},{"json":"95","pairedItem":"94"},{"json":"96","pairedItem":"94"},{"json":"97","pairedItem":"94"},{"json":"98","pairedItem":"94"},{"json":"99","pairedItem":"94"},{"json":"100","pairedItem":"94"},{"json":"101","pairedItem":"94"},{"json":"102","pairedItem":"94"},{"json":"103","pairedItem":"94"},{"json":"104","pairedItem":"94"},{"json":"105","pairedItem":"94"},{"json":"106"},{"json":"106","pairedItem":"107"},{"headers":"108","params":"109","query":"110","body":"111","webhookUrl":"112","executionMode":"113"},{"item":0},{"valid":true,"userId":1,"conversationId":"114"},{"item":0},{"item":0},{"message_id":1,"role":"115","content":"116","created_at":"117"},{"item":0},{"message_id":2,"role":"118","content":"119","created_at":"120"},{"message_id":3,"role":"115","content":"121","created_at":"122"},{"message_id":4,"role":"118","content":"123","created_at":"124"},{"message_id":5,"role":"115","content":"125","created_at":"126"},{"message_id":6,"role":"118","content":"127","created_at":"128"},{"message_id":27,"role":"115","content":"129","created_at":"130"},{"message_id":28,"role":"118","content":"131","created_at":"130"},{"message_id":29,"role":"115","content":"132","created_at":"133"},{"message_id":30,"role":"118","content":"134","created_at":"133"},{"message_id":31,"role":"115","content":"135","created_at":"136"},{"message_id":32,"role":"118","content":"137","created_at":"136"},{"success":true,"messages":"138"},{"item":0},{"host":"139","x-real-ip":"140","x-forwarded-for":"140","x-forwarded-proto":"141","connection":"142","sec-ch-ua-platform":"143","authorization":"144","user-agent":"145","accept":"146","sec-ch-ua":"147","dnt":"148","sec-ch-ua-mobile":"149","sec-fetch-site":"150","sec-fetch-mode":"151","sec-fetch-dest":"152","referer":"153","accept-encoding":"154","accept-language":"155","cookie":"156","sec-gpc":"148","if-none-match":"157"},{},{"conversationId":"114"},{},"http://localhost:5678/webhook/wibot/messages","production","550e8400-e29b-41d4-a716-446655440000","user","Bonjour WIBOT !","2025-12-24T07:42:15Z","assistant","Bonjour ! Je suis WIBOT, l'assistant IA de WIDIP. Comment puis-je t'aider aujourd'hui ?","2025-12-24T07:42:17Z","Peux-tu m'expliquer comment fonctionne PostgreSQL ?","2025-12-24T07:43:15Z","PostgreSQL est un systeme de gestion de base de donnees relationnelle (SGBDR) open source tres puissant.\\n\\n**Caracteristiques principales :**\\n- Support complet SQL\\n- Transactions ACID\\n- Extensions (comme pgcrypto pour le chiffrement)\\n- Excellent pour les charges de travail complexes\\n\\nC'est ce qu'on utilise chez WIDIP pour stocker les donnees WIBOT !","2025-12-24T07:43:20Z","Et comment faire un backup ?","2025-12-25T07:42:15Z","Pour faire un backup PostgreSQL, tu as plusieurs options :\\n\\n```bash\\n# Backup complet (dump SQL)\\npg_dump -U widip -d wibot > backup.sql\\n\\n# Backup compresse\\npg_dump -U widip -d wibot | gzip > backup.sql.gz\\n\\n# Restauration\\npsql -U widip -d wibot < backup.sql\\n```\\n\\nPour les backups automatiques, on peut utiliser un cron job ou un workflow n8n !","2025-12-25T07:42:18Z","salut","2025-12-26T17:16:30Z","Salut ! Comment puis-je vous aider aujourd'hui ?","ddadzax","2025-12-26T17:16:38Z","Bonjour ! Je ne suis pas sûr de comprendre votre demande. Pourriez-vous préciser ou reformuler votre question ? Je suis là pour vous aider avec les questions techniques ou toute autre demande liée à WIDIP.","hey","2025-12-26T17:28:13Z","Bonjour ! Comment puis-je vous aider aujourd'hui ?",["158","159","160","161","162","163","164","165","166","167","168","169"],"localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzAwODYsImV4cCI6MTc2Njg1NjQ4Nn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","W/\\"8c1-97WpuvK54GrQdO+AMWrIvvfcngA\\"",{"message_id":1,"role":"115","content":"116","created_at":"117"},{"message_id":2,"role":"118","content":"119","created_at":"120"},{"message_id":3,"role":"115","content":"121","created_at":"122"},{"message_id":4,"role":"118","content":"123","created_at":"124"},{"message_id":5,"role":"115","content":"125","created_at":"126"},{"message_id":6,"role":"118","content":"127","created_at":"128"},{"message_id":27,"role":"115","content":"129","created_at":"130"},{"message_id":28,"role":"118","content":"131","created_at":"130"},{"message_id":29,"role":"115","content":"132","created_at":"133"},{"message_id":30,"role":"118","content":"134","created_at":"133"},{"message_id":31,"role":"115","content":"135","created_at":"136"},{"message_id":32,"role":"118","content":"137","created_at":"136"}]
101	{"id":"msg5c740bd9db51","name":"WIBOT - Get Messages","active":true,"activeVersionId":"704bc444-e5e2-4901-9322-383bc1bd0434","isArchived":false,"createdAt":"2025-12-26T17:58:10.218Z","updatedAt":"2025-12-26T17:58:10.218Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/messages","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"webhook-messages","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,300],"webhookId":"wibot-messages"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst conversationId = $input.first().json.query.conversationId;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nif (!conversationId) {\\n  return [{ json: { valid: false, error: 'conversationId is required' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId, conversationId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"verify-jwt","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[470,300]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"if-jwt-valid","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[690,300]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-unauthorized","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[910,450]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  m.message_id,\\n  m.role,\\n  m.content,\\n  TO_CHAR(m.created_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as created_at\\nFROM messages m\\nJOIN conversations c ON m.conversation_id = c.conversation_id\\nWHERE m.conversation_id = '{{ $json.conversationId }}'::uuid\\n  AND c.user_id = {{ $json.userId }}\\nORDER BY m.created_at ASC;","options":{}},"id":"get-messages","name":"Get Messages","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[910,200],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats, retourner liste vide\\nif (!rows || rows.length === 0 || !rows[0].json.message_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      messages: []\\n    }\\n  }];\\n}\\n\\nconst messages = rows.map(row => ({\\n  message_id: row.json.message_id,\\n  role: row.json.role,\\n  content: row.json.content,\\n  created_at: row.json.created_at\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    messages\\n  }\\n}];","notice":""},"id":"format-response","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1130,200]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-success","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1350,200]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Messages","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Messages":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Messages":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766772153491,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766772153491,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766772153491,"executionIndex":1,"source":"29","hints":"30","executionTime":3,"executionStatus":"27","data":"31"},{"startTime":1766772153494,"executionIndex":2,"source":"32","hints":"33","executionTime":0,"executionStatus":"27","data":"34"},{"startTime":1766772153494,"executionIndex":3,"source":"35","hints":"36","executionTime":3,"executionStatus":"27","data":"37"},{"startTime":1766772153497,"executionIndex":4,"source":"38","hints":"39","executionTime":3,"executionStatus":"27","data":"40"},{"startTime":1766772153500,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75","76","77","78","79","80","81"],"Get Messages",["82"],"Format Response",["83"],{"json":"84","pairedItem":"85"},{"json":"86","pairedItem":"87"},{"json":"86","pairedItem":"88"},{"json":"89","pairedItem":"90"},{"json":"91","pairedItem":"90"},{"json":"92","pairedItem":"90"},{"json":"93","pairedItem":"90"},{"json":"94","pairedItem":"90"},{"json":"95","pairedItem":"90"},{"json":"96","pairedItem":"90"},{"json":"97","pairedItem":"90"},{"json":"98"},{"json":"98","pairedItem":"99"},{"headers":"100","params":"101","query":"102","body":"103","webhookUrl":"104","executionMode":"105"},{"item":0},{"valid":true,"userId":1,"conversationId":"106"},{"item":0},{"item":0},{"message_id":21,"role":"107","content":"108","created_at":"109"},{"item":0},{"message_id":22,"role":"110","content":"111","created_at":"109"},{"message_id":23,"role":"107","content":"112","created_at":"113"},{"message_id":24,"role":"110","content":"114","created_at":"113"},{"message_id":25,"role":"107","content":"112","created_at":"115"},{"message_id":26,"role":"110","content":"116","created_at":"115"},{"message_id":33,"role":"107","content":"117","created_at":"118"},{"message_id":34,"role":"110","content":"119","created_at":"118"},{"success":true,"messages":"120"},{"item":0},{"host":"121","x-real-ip":"122","x-forwarded-for":"122","x-forwarded-proto":"123","connection":"124","sec-ch-ua-platform":"125","authorization":"126","user-agent":"127","accept":"128","sec-ch-ua":"129","dnt":"130","sec-ch-ua-mobile":"131","sec-fetch-site":"132","sec-fetch-mode":"133","sec-fetch-dest":"134","referer":"135","accept-encoding":"136","accept-language":"137","cookie":"138","sec-gpc":"130","if-none-match":"139"},{},{"conversationId":"106"},{},"http://localhost:5678/webhook/wibot/messages","production","963eb9f1-fdcc-4cd5-918b-29fae40c17a0","user","quel est le chiffre important que je t'ai donné ?","2025-12-26T16:45:37Z","assistant","Je n'ai pas de mémoire persistante entre nos interactions, donc je ne peux pas me souvenir des informations partagées lors de nos précédentes conversations. Si vous me donnez à nouveau le chiffre important, je serai ravi de vous aider avec celui-ci.\\n\\nN'hésitez pas à me le communiquer !","salut","2025-12-26T17:13:49Z","Salut ! Comment puis-je vous aider aujourd'hui ? 😊","2025-12-26T17:14:33Z","Bonjour ! Comment puis-je vous aider aujourd'hui ? 😊","dsf ça va ?","2025-12-26T17:34:13Z","Bonjour ! Je vais très bien, merci de demander. 😊\\n\\nComment puis-je vous aider aujourd'hui ?",["140","141","142","143","144","145","146","147"],"localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzAwODYsImV4cCI6MTc2Njg1NjQ4Nn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","W/\\"4f5-iX7OrMLhqWRZ+Pgvd44GsjyMq3A\\"",{"message_id":21,"role":"107","content":"108","created_at":"109"},{"message_id":22,"role":"110","content":"111","created_at":"109"},{"message_id":23,"role":"107","content":"112","created_at":"113"},{"message_id":24,"role":"110","content":"114","created_at":"113"},{"message_id":25,"role":"107","content":"112","created_at":"115"},{"message_id":26,"role":"110","content":"116","created_at":"115"},{"message_id":33,"role":"107","content":"117","created_at":"118"},{"message_id":34,"role":"110","content":"119","created_at":"118"}]
103	{"id":"NynEDh5rxUQL7788","name":"WIBOT - Chat Main","active":true,"activeVersionId":"7924c06c-c403-4b11-a377-81bbcf664b88","isArchived":false,"createdAt":"2025-12-26T17:23:30.579Z","updatedAt":"2025-12-26T17:24:09.477Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"POST","path":"wibot/chat","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"fa8ec4be-706d-4001-ad6c-fcb0f99736af","name":"Webhook Chat","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-1328,112],"webhookId":"wibot-chat"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst body = $input.first().json.body;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  // Decode base64url payload\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  // Check expiration\\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ \\n    json: { \\n      valid: true, \\n      user: decoded,\\n      userId: decoded.userId,\\n      conversationId: body.conversation_id,\\n      message: body.message,\\n      sessionId: `${decoded.userId}_${body.conversation_id}`\\n    } \\n  }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"0004c18c-eca3-41dc-997e-590e7fd79356","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-1104,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"bfcef1a4-73b6-486c-aab3-5977d98eb079","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-880,112]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"cba8bdb1-b75a-4f70-aa59-b7a0eda05fa5","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[-656,352]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  COALESCE(used_tokens, 0) as used_tokens,\\n  COALESCE(quota_tokens, 50000) as quota_tokens\\nFROM user_token_usage\\nWHERE user_id = {{ $json.userId }}\\n  AND month = DATE_TRUNC('month', CURRENT_DATE)\\nLIMIT 1;","options":{}},"id":"c95bf25e-6737-45ac-a7bb-499bc0b7c7dc","name":"Check Quota","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[-656,112],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\nconst jwtData = $('Verify JWT').first().json;\\n\\nlet usedTokens = 0;\\nlet quotaTokens = 50000;\\n\\nif (rows && rows.length > 0 && rows[0].json.used_tokens !== undefined) {\\n  usedTokens = parseInt(rows[0].json.used_tokens) || 0;\\n  quotaTokens = parseInt(rows[0].json.quota_tokens) || 50000;\\n}\\n\\nconst quotaExceeded = usedTokens >= quotaTokens;\\n\\nreturn [{\\n  json: {\\n    ...jwtData,\\n    usedTokens,\\n    quotaTokens,\\n    quotaExceeded\\n  }\\n}];","notice":""},"id":"4a1c034d-d824-4eec-8f7d-30e703f1deb5","name":"Prepare Quota","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-quota-ok","leftValue":"={{ $json.quotaExceeded }}","rightValue":false,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"19cfec26-6daa-4bf5-a4dd-9c46bc7e775a","name":"Quota OK?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"Quota tokens mensuel depass\\\\u00e9. Limite : 50,000 tokens/mois.\\",\\n  \\"code\\": \\"QUOTA_EXCEEDED\\"\\n}","options":{"responseCode":429,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"664cd109-b947-42ee-b8c1-42b595e37b31","name":"Quota Exceeded","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"aiAgentStarterCallout":"","preBuiltAgentsCallout":"","agent":"toolsAgent","promptType":"define","text":"={{ $json.message }}","hasOutputParser":false,"options":{"systemMessage":"Tu es WIBOT, l'assistant IA interne de WIDIP, une entreprise francaise de services informatiques.\\n\\nTon role:\\n- Aider les employes WIDIP avec leurs questions techniques\\n- Fournir des reponses claires et professionnelles\\n- Utiliser le francais par defaut\\n- Etre concis mais complet\\n\\nStyle:\\n- Utilise le markdown pour formater tes reponses\\n- Mets le code dans des blocs avec le langage specifie\\n- Sois amical mais professionnel"},"credentials":""},"id":"9e04ca0c-5683-4a62-828d-5c057cf62605","name":"AI Agent","type":"@n8n/n8n-nodes-langchain.agent","typeVersion":1.7,"position":[0,0]},{"parameters":{"notice":"","model":"mistral-small-latest","options":{"maxTokens":2048,"temperature":0.7}},"id":"1668e2c3-0095-4fbb-877e-e60722e8d24b","name":"Mistral Cloud Chat Model","type":"@n8n/n8n-nodes-langchain.lmChatMistralCloud","typeVersion":1,"position":[-208,304],"credentials":{"mistralCloudApi":{"id":"b9hl3JA2taufCYVr","name":"Mistral API"}}},{"parameters":{"notice":"","sessionIdType":"customKey","sessionKey":"={{ $('Verify JWT').first().json.sessionId }}","tableName":"n8n_chat_histories","contextWindowLength":10},"id":"cffc5919-5412-4308-9671-843b8d2d035f","name":"Postgres Chat Memory","type":"@n8n/n8n-nodes-langchain.memoryPostgresChat","typeVersion":1.3,"position":[0,304],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const agentResponse = $input.first().json.output;\\nconst jwtData = $('Prepare Quota').first().json;\\n\\n// Estimation tokens (environ 4 chars par token)\\nconst messageTokens = Math.ceil(jwtData.message.length / 4);\\nconst responseTokens = Math.ceil(agentResponse.length / 4);\\nconst tokensUsed = messageTokens + responseTokens;\\n\\nconst newUsedTokens = jwtData.usedTokens + tokensUsed;\\nconst tokensRemaining = jwtData.quotaTokens - newUsedTokens;\\n\\nreturn [{\\n  json: {\\n    userId: jwtData.userId,\\n    conversationId: jwtData.conversationId,\\n    message: jwtData.message,\\n    response: agentResponse,\\n    tokensUsed,\\n    newUsedTokens,\\n    tokensRemaining: Math.max(0, tokensRemaining),\\n    quotaTokens: jwtData.quotaTokens\\n  }\\n}];","notice":""},"id":"b2c9d072-5736-4839-9f3f-8c63b5fe8801","name":"Prepare Save","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"resource":"database","operation":"executeQuery","query":"INSERT INTO conversations (conversation_id, user_id, title, created_at, updated_at)\\nVALUES (\\n  '{{ $json.conversationId }}'::uuid,\\n  {{ $json.userId }},\\n  '{{ $json.message.substring(0, 50).replace(/'/g, \\"''\\") }}',\\n  NOW(),\\n  NOW()\\n)\\nON CONFLICT (conversation_id)\\nDO UPDATE SET updated_at = NOW();","options":{}},"id":"6c1ace5b-ec88-44b5-a9b5-182a4957e5c9","name":"UPSERT Conversation","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[448,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"resource":"database","operation":"executeQuery","query":"INSERT INTO messages (conversation_id, user_id, role, content, tokens, created_at)\\nVALUES (\\n  '{{ $('Prepare Save').first().json.conversationId }}'::uuid,\\n  {{ $('Prepare Save').first().json.userId }},\\n  'user',\\n  '{{ $('Prepare Save').first().json.message.replace(/'/g, \\"''\\").replace(/\\\\\\\\/g, '\\\\\\\\\\\\\\\\') }}',\\n  {{ Math.ceil($('Prepare Save').first().json.message.length / 4) }},\\n  NOW()\\n);","options":{}},"id":"19bf528f-0b9d-44d5-b768-58e63ddee026","name":"INSERT User Message","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[672,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"resource":"database","operation":"executeQuery","query":"INSERT INTO messages (conversation_id, user_id, role, content, tokens, created_at)\\nVALUES (\\n  '{{ $('Prepare Save').first().json.conversationId }}'::uuid,\\n  {{ $('Prepare Save').first().json.userId }},\\n  'assistant',\\n  '{{ $('Prepare Save').first().json.response.replace(/'/g, \\"''\\").replace(/\\\\\\\\/g, '\\\\\\\\\\\\\\\\') }}',\\n  {{ Math.ceil($('Prepare Save').first().json.response.length / 4) }},\\n  NOW()\\n);","options":{}},"id":"22a33991-a55c-428d-b673-3b0eef3b8a1a","name":"INSERT Assistant Message","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[880,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"resource":"database","operation":"executeQuery","query":"INSERT INTO user_token_usage (user_id, month, used_tokens, quota_tokens)\\nVALUES (\\n  {{ $('Prepare Save').first().json.userId }},\\n  DATE_TRUNC('month', CURRENT_DATE),\\n  {{ $('Prepare Save').first().json.tokensUsed }},\\n  50000\\n)\\nON CONFLICT (user_id, month)\\nDO UPDATE SET used_tokens = user_token_usage.used_tokens + {{ $('Prepare Save').first().json.tokensUsed }};","options":{}},"id":"344a1edc-fdf7-4ba0-a506-10b00624a0ac","name":"UPDATE Token Usage","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[1104,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const data = $('Prepare Save').first().json;\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    response: data.response,\\n    tokens_used: data.tokensUsed,\\n    tokens_remaining: data.tokensRemaining,\\n    conversation_id: data.conversationId\\n  }\\n}];","notice":""},"id":"d3257586-4db1-4ccf-8b88-2ec7203c06ee","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1328,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"bfca5f39-23d9-494d-9b4e-767225255749","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1552,0]}],"connections":{"Webhook Chat":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Check Quota","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Check Quota":{"main":[[{"node":"Prepare Quota","type":"main","index":0}]]},"Prepare Quota":{"main":[[{"node":"Quota OK?","type":"main","index":0}]]},"Quota OK?":{"main":[[{"node":"AI Agent","type":"main","index":0}],[{"node":"Quota Exceeded","type":"main","index":0}]]},"Mistral Cloud Chat Model":{"ai_languageModel":[[{"node":"AI Agent","type":"ai_languageModel","index":0}]]},"Postgres Chat Memory":{"ai_memory":[[{"node":"AI Agent","type":"ai_memory","index":0}]]},"AI Agent":{"main":[[{"node":"Prepare Save","type":"main","index":0}]]},"Prepare Save":{"main":[[{"node":"UPSERT Conversation","type":"main","index":0}]]},"UPSERT Conversation":{"main":[[{"node":"INSERT User Message","type":"main","index":0}]]},"INSERT User Message":{"main":[[{"node":"INSERT Assistant Message","type":"main","index":0}]]},"INSERT Assistant Message":{"main":[[{"node":"UPDATE Token Usage","type":"main","index":0}]]},"UPDATE Token Usage":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook Chat":"12","Verify JWT":"13","JWT Valid?":"14","Check Quota":"15","Prepare Quota":"16","Quota OK?":"17","Postgres Chat Memory":"18","Mistral Cloud Chat Model":"19","AI Agent":"20","Prepare Save":"21","UPSERT Conversation":"22","INSERT User Message":"23","INSERT Assistant Message":"24","UPDATE Token Usage":"25","Format Response":"26","Success":"27"},"Success",{},[],{"Postgres Chat Memory":"28","Mistral Cloud Chat Model":"29"},{},{},{"version":1,"establishedAt":1766772174692,"source":"30"},["31"],["32"],["33"],["34"],["35"],["36"],["37","38"],["39"],["40"],["41"],["42"],["43"],["44"],["45"],["46"],["47"],["48","49"],["50"],"webhook",{"startTime":1766772174692,"executionIndex":0,"source":"51","hints":"52","executionTime":0,"executionStatus":"53","data":"54"},{"startTime":1766772174692,"executionIndex":1,"source":"55","hints":"56","executionTime":3,"executionStatus":"53","data":"57"},{"startTime":1766772174695,"executionIndex":2,"source":"58","hints":"59","executionTime":1,"executionStatus":"53","data":"60"},{"startTime":1766772174696,"executionIndex":3,"source":"61","hints":"62","executionTime":8,"executionStatus":"53","data":"63"},{"startTime":1766772174704,"executionIndex":4,"source":"64","hints":"65","executionTime":3,"executionStatus":"53","data":"66"},{"startTime":1766772174707,"executionIndex":5,"source":"67","hints":"68","executionTime":3,"executionStatus":"53","data":"69"},{"startTime":1766772174742,"executionTime":7,"executionIndex":7,"executionStatus":"53","source":"70","data":"71","inputOverride":"72","metadata":"73"},{"startTime":1766772175899,"executionTime":6,"executionIndex":9,"executionStatus":"53","source":"74","data":"75","inputOverride":"76","metadata":"77"},{"startTime":1766772175151,"executionTime":738,"executionIndex":8,"executionStatus":"53","source":"78","data":"79","inputOverride":"80","metadata":"81"},{"startTime":1766772174710,"executionIndex":6,"source":"82","hints":"83","executionTime":1195,"executionStatus":"53","data":"84"},{"startTime":1766772175905,"executionIndex":10,"source":"85","hints":"86","executionTime":3,"executionStatus":"53","data":"87"},{"startTime":1766772175908,"executionIndex":11,"source":"88","hints":"89","executionTime":8,"executionStatus":"53","data":"90"},{"startTime":1766772175916,"executionIndex":12,"source":"91","hints":"92","executionTime":16,"executionStatus":"53","data":"93"},{"startTime":1766772175932,"executionIndex":13,"source":"94","hints":"95","executionTime":9,"executionStatus":"53","data":"96"},{"startTime":1766772175941,"executionIndex":14,"source":"97","hints":"98","executionTime":5,"executionStatus":"53","data":"99"},{"startTime":1766772175946,"executionIndex":15,"source":"100","hints":"101","executionTime":3,"executionStatus":"53","data":"102"},{"startTime":1766772175949,"executionIndex":16,"source":"103","hints":"104","executionTime":1,"executionStatus":"53","data":"105"},{"subRun":"106"},{"subRun":"107"},{"subRun":"108"},[],[],"success",{"main":"109"},["110"],["111"],{"main":"112"},["113"],[],{"main":"114"},["115"],[],{"main":"116"},["117"],["118"],{"main":"119"},["120"],[],{"main":"121"},["122"],{"ai_memory":"123"},{"ai_memory":"124"},{"subRun":"106"},["125"],{"ai_memory":"126"},{"ai_memory":"127"},{"subRun":"107"},["128"],{"ai_languageModel":"129"},{"ai_languageModel":"130"},{"subRun":"108"},["131"],[],{"main":"132"},["133"],["134"],{"main":"135"},["136"],[],{"main":"137"},["138"],[],{"main":"139"},["140"],[],{"main":"141"},["142"],[],{"main":"143"},["144"],["145"],{"main":"146"},["147"],[],{"main":"148"},["149"],["150"],["151"],["152"],{"previousNode":"153"},{"message":"154","location":"155"},["156"],{"previousNode":"157"},["158","159"],{"previousNode":"160"},["161"],{"previousNode":"162"},{"message":"154","location":"155"},["163"],{"previousNode":"164"},["165","166"],{"previousNode":"167","previousNodeRun":0},["168"],["169"],{"previousNode":"167","previousNodeRun":0},["170"],["171"],{"previousNode":"167","previousNodeRun":0},["172"],["173"],{"previousNode":"174"},["175"],{"previousNode":"167"},{"message":"154","location":"155"},["176"],{"previousNode":"177"},["178"],{"previousNode":"179"},["180"],{"previousNode":"181"},["182"],{"previousNode":"183"},["184"],{"previousNode":"185"},{"message":"154","location":"155"},["186"],{"previousNode":"187"},["188"],{"node":"189","runIndex":0},{"node":"189","runIndex":1},{"node":"190","runIndex":0},["191"],"Webhook Chat","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["192"],"Verify JWT",["193"],[],"JWT Valid?",["194"],"Check Quota",["195"],"Prepare Quota",["196"],[],"AI Agent",["197"],["198"],["199"],["200"],["201"],["202"],"Quota OK?",["203"],["204"],"Prepare Save",["205"],"UPSERT Conversation",["206"],"INSERT User Message",["207"],"INSERT Assistant Message",["208"],"UPDATE Token Usage",["209"],"Format Response",["210"],"Postgres Chat Memory","Mistral Cloud Chat Model",{"json":"211","pairedItem":"212"},{"json":"213","pairedItem":"214"},{"json":"213","pairedItem":"215"},{"json":"216","pairedItem":"217"},{"json":"218","pairedItem":"219"},{"json":"218","pairedItem":"220"},{"json":"221"},{"json":"222"},{"json":"223"},{"json":"224"},{"json":"225"},{"json":"226"},{"json":"227","pairedItem":"228"},{"json":"229","pairedItem":"230"},{"json":"231","pairedItem":"232"},{"json":"233","pairedItem":"234"},{"json":"235","pairedItem":"236"},{"json":"237","pairedItem":"238"},{"json":"239","pairedItem":"240"},{"json":"239","pairedItem":"241"},{"headers":"242","params":"243","query":"244","body":"245","webhookUrl":"246","executionMode":"247"},{"item":0},{"valid":true,"user":"248","userId":1,"conversationId":"249","message":"250","sessionId":"251"},{"item":0},{"item":0},{"used_tokens":"252","quota_tokens":"253"},{"item":0},{"valid":true,"user":"254","userId":1,"conversationId":"249","message":"250","sessionId":"251","usedTokens":14289,"quotaTokens":50000,"quotaExceeded":false},{"item":0},{"item":0},{"action":"255","chatHistory":"256"},{"action":"255","values":"257"},{"action":"258","chatHistory":"259"},{"action":"258","input":"260","output":"261"},{"response":"262","tokenUsage":"263"},{"messages":"264","estimatedTokens":114,"options":"265"},{"output":"266"},{"item":0},{"userId":1,"conversationId":"249","message":"250","response":"266","tokensUsed":64,"newUsedTokens":14353,"tokensRemaining":35647,"quotaTokens":50000},{"item":0},{"success":true},["267"],{"success":true},["268"],{"success":true},["269"],{"success":true},["270"],{"success":true,"response":"266","tokens_used":64,"tokens_remaining":35647,"conversation_id":"249"},{"item":0},{"item":0},{"host":"271","x-real-ip":"272","x-forwarded-for":"272","x-forwarded-proto":"273","connection":"274","content-length":"275","sec-ch-ua-platform":"276","authorization":"277","sec-ch-ua":"278","sec-ch-ua-mobile":"279","user-agent":"280","accept":"281","dnt":"282","content-type":"283","origin":"284","sec-fetch-site":"285","sec-fetch-mode":"286","sec-fetch-dest":"287","referer":"288","accept-encoding":"289","accept-language":"290","cookie":"291","sec-gpc":"282"},{},{},{"conversation_id":"249","message":"250"},"http://localhost:5678/webhook/wibot/chat","production",{"userId":1,"username":"292","role":"293","iat":1766770086,"exp":1766856486},"419ba4c9-f14d-4af2-83b3-ba2399c17ffb","tu es tristes ?","1_419ba4c9-f14d-4af2-83b3-ba2399c17ffb","14289","50000",{"userId":1,"username":"292","role":"293","iat":1766770086,"exp":1766856486},"loadMemoryVariables",[],{"input":"250","system_message":"294","formatting_instructions":"295"},"saveContext",["296","297"],{"input":"250","system_message":"294","formatting_instructions":"295"},{"input":"250","system_message":"294","formatting_instructions":"295","chat_history":"256","output":"266"},{"generations":"298"},{"completionTokens":56,"promptTokens":116,"totalTokens":172},["299"],{"mistral_api_key":"300","model":"301","max_tokens":2048,"temperature":0.7,"metadata":"302"},"Non, je ne suis pas triste. En tant qu'IA, je n'ai pas de sentiments ou d'émotions. Mon rôle est de vous aider avec vos questions techniques et de fournir des réponses claires et professionnelles. Comment puis-je vous aider aujourd'hui ?",{"item":0},{"item":0},{"item":0},{"item":0},"localhost","172.20.0.1","http","close","86","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzAwODYsImV4cCI6MTc2Njg1NjQ4Nn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","?0","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","1","application/json","http://localhost:5173","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","khora","admin","Tu es WIBOT, l'assistant IA interne de WIDIP, une entreprise francaise de services informatiques.\\n\\nTon role:\\n- Aider les employes WIDIP avec leurs questions techniques\\n- Fournir des reponses claires et professionnelles\\n- Utiliser le francais par defaut\\n- Etre concis mais complet\\n\\nStyle:\\n- Utilise le markdown pour formater tes reponses\\n- Mets le code dans des blocs avec le langage specifie\\n- Sois amical mais professionnel","IMPORTANT: For your response to user, you MUST use the `format_final_json_response` tool with your complete answer formatted according to the required schema. Do not attempt to format the JSON manually - always use this tool. Your response will be rejected if it is not properly formatted through this tool. Only use this tool once you are ready to provide your final answer.",{"lc":1,"type":"303","id":"304","kwargs":"305"},{"lc":1,"type":"303","id":"306","kwargs":"307"},["308"],"System: Tu es WIBOT, l'assistant IA interne de WIDIP, une entreprise francaise de services informatiques.\\n\\nTon role:\\n- Aider les employes WIDIP avec leurs questions techniques\\n- Fournir des reponses claires et professionnelles\\n- Utiliser le francais par defaut\\n- Etre concis mais complet\\n\\nStyle:\\n- Utilise le markdown pour formater tes reponses\\n- Mets le code dans des blocs avec le langage specifie\\n- Sois amical mais professionnel\\nHuman: tu es tristes ?",{"lc":1,"type":"309","id":"310"},"mistral-small-latest",{},"constructor",["311","312","313"],{"content":"250","additional_kwargs":"314","response_metadata":"315"},["311","312","316"],{"content":"266","tool_calls":"317","additional_kwargs":"318","response_metadata":"319","invalid_tool_calls":"320"},["321"],"secret",["322"],"langchain_core","messages","HumanMessage",{},{},"AIMessage",[],{},{},[],{"text":"266","generationInfo":"323"},"MISTRAL_API_KEY",{"prompt":0,"completion":0}]
104	{"id":"msg5c740bd9db51","name":"WIBOT - Get Messages","active":true,"activeVersionId":"704bc444-e5e2-4901-9322-383bc1bd0434","isArchived":false,"createdAt":"2025-12-26T17:58:10.218Z","updatedAt":"2025-12-26T17:58:10.218Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/messages","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"webhook-messages","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,300],"webhookId":"wibot-messages"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst conversationId = $input.first().json.query.conversationId;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nif (!conversationId) {\\n  return [{ json: { valid: false, error: 'conversationId is required' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId, conversationId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"verify-jwt","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[470,300]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"if-jwt-valid","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[690,300]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-unauthorized","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[910,450]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  m.message_id,\\n  m.role,\\n  m.content,\\n  TO_CHAR(m.created_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as created_at\\nFROM messages m\\nJOIN conversations c ON m.conversation_id = c.conversation_id\\nWHERE m.conversation_id = '{{ $json.conversationId }}'::uuid\\n  AND c.user_id = {{ $json.userId }}\\nORDER BY m.created_at ASC;","options":{}},"id":"get-messages","name":"Get Messages","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[910,200],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats, retourner liste vide\\nif (!rows || rows.length === 0 || !rows[0].json.message_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      messages: []\\n    }\\n  }];\\n}\\n\\nconst messages = rows.map(row => ({\\n  message_id: row.json.message_id,\\n  role: row.json.role,\\n  content: row.json.content,\\n  created_at: row.json.created_at\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    messages\\n  }\\n}];","notice":""},"id":"format-response","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1130,200]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-success","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1350,200]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Messages","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Messages":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Messages":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766772178141,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766772178142,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766772178142,"executionIndex":1,"source":"29","hints":"30","executionTime":4,"executionStatus":"27","data":"31"},{"startTime":1766772178146,"executionIndex":2,"source":"32","hints":"33","executionTime":0,"executionStatus":"27","data":"34"},{"startTime":1766772178146,"executionIndex":3,"source":"35","hints":"36","executionTime":3,"executionStatus":"27","data":"37"},{"startTime":1766772178149,"executionIndex":4,"source":"38","hints":"39","executionTime":2,"executionStatus":"27","data":"40"},{"startTime":1766772178152,"executionIndex":5,"source":"41","hints":"42","executionTime":0,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75","76","77","78","79","80","81"],"Get Messages",["82"],"Format Response",["83"],{"json":"84","pairedItem":"85"},{"json":"86","pairedItem":"87"},{"json":"86","pairedItem":"88"},{"json":"89","pairedItem":"90"},{"json":"91","pairedItem":"90"},{"json":"92","pairedItem":"90"},{"json":"93","pairedItem":"90"},{"json":"94","pairedItem":"90"},{"json":"95","pairedItem":"90"},{"json":"96","pairedItem":"90"},{"json":"97","pairedItem":"90"},{"json":"98"},{"json":"98","pairedItem":"99"},{"headers":"100","params":"101","query":"102","body":"103","webhookUrl":"104","executionMode":"105"},{"item":0},{"valid":true,"userId":1,"conversationId":"106"},{"item":0},{"item":0},{"message_id":21,"role":"107","content":"108","created_at":"109"},{"item":0},{"message_id":22,"role":"110","content":"111","created_at":"109"},{"message_id":23,"role":"107","content":"112","created_at":"113"},{"message_id":24,"role":"110","content":"114","created_at":"113"},{"message_id":25,"role":"107","content":"112","created_at":"115"},{"message_id":26,"role":"110","content":"116","created_at":"115"},{"message_id":33,"role":"107","content":"117","created_at":"118"},{"message_id":34,"role":"110","content":"119","created_at":"118"},{"success":true,"messages":"120"},{"item":0},{"host":"121","x-real-ip":"122","x-forwarded-for":"122","x-forwarded-proto":"123","connection":"124","sec-ch-ua-platform":"125","authorization":"126","user-agent":"127","accept":"128","sec-ch-ua":"129","dnt":"130","sec-ch-ua-mobile":"131","sec-fetch-site":"132","sec-fetch-mode":"133","sec-fetch-dest":"134","referer":"135","accept-encoding":"136","accept-language":"137","cookie":"138","sec-gpc":"130","if-none-match":"139"},{},{"conversationId":"106"},{},"http://localhost:5678/webhook/wibot/messages","production","963eb9f1-fdcc-4cd5-918b-29fae40c17a0","user","quel est le chiffre important que je t'ai donné ?","2025-12-26T16:45:37Z","assistant","Je n'ai pas de mémoire persistante entre nos interactions, donc je ne peux pas me souvenir des informations partagées lors de nos précédentes conversations. Si vous me donnez à nouveau le chiffre important, je serai ravi de vous aider avec celui-ci.\\n\\nN'hésitez pas à me le communiquer !","salut","2025-12-26T17:13:49Z","Salut ! Comment puis-je vous aider aujourd'hui ? 😊","2025-12-26T17:14:33Z","Bonjour ! Comment puis-je vous aider aujourd'hui ? 😊","dsf ça va ?","2025-12-26T17:34:13Z","Bonjour ! Je vais très bien, merci de demander. 😊\\n\\nComment puis-je vous aider aujourd'hui ?",["140","141","142","143","144","145","146","147"],"localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzAwODYsImV4cCI6MTc2Njg1NjQ4Nn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","W/\\"4f5-iX7OrMLhqWRZ+Pgvd44GsjyMq3A\\"",{"message_id":21,"role":"107","content":"108","created_at":"109"},{"message_id":22,"role":"110","content":"111","created_at":"109"},{"message_id":23,"role":"107","content":"112","created_at":"113"},{"message_id":24,"role":"110","content":"114","created_at":"113"},{"message_id":25,"role":"107","content":"112","created_at":"115"},{"message_id":26,"role":"110","content":"116","created_at":"115"},{"message_id":33,"role":"107","content":"117","created_at":"118"},{"message_id":34,"role":"110","content":"119","created_at":"118"}]
105	{"id":"msg5c740bd9db51","name":"WIBOT - Get Messages","active":true,"activeVersionId":"704bc444-e5e2-4901-9322-383bc1bd0434","isArchived":false,"createdAt":"2025-12-26T17:58:10.218Z","updatedAt":"2025-12-26T17:58:10.218Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/messages","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"webhook-messages","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,300],"webhookId":"wibot-messages"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst conversationId = $input.first().json.query.conversationId;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nif (!conversationId) {\\n  return [{ json: { valid: false, error: 'conversationId is required' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId, conversationId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"verify-jwt","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[470,300]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"if-jwt-valid","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[690,300]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-unauthorized","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[910,450]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  m.message_id,\\n  m.role,\\n  m.content,\\n  TO_CHAR(m.created_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as created_at\\nFROM messages m\\nJOIN conversations c ON m.conversation_id = c.conversation_id\\nWHERE m.conversation_id = '{{ $json.conversationId }}'::uuid\\n  AND c.user_id = {{ $json.userId }}\\nORDER BY m.created_at ASC;","options":{}},"id":"get-messages","name":"Get Messages","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[910,200],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats, retourner liste vide\\nif (!rows || rows.length === 0 || !rows[0].json.message_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      messages: []\\n    }\\n  }];\\n}\\n\\nconst messages = rows.map(row => ({\\n  message_id: row.json.message_id,\\n  role: row.json.role,\\n  content: row.json.content,\\n  created_at: row.json.created_at\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    messages\\n  }\\n}];","notice":""},"id":"format-response","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1130,200]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-success","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1350,200]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Messages","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Messages":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Messages":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766772180856,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766772180856,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766772180856,"executionIndex":1,"source":"29","hints":"30","executionTime":3,"executionStatus":"27","data":"31"},{"startTime":1766772180860,"executionIndex":2,"source":"32","hints":"33","executionTime":0,"executionStatus":"27","data":"34"},{"startTime":1766772180860,"executionIndex":3,"source":"35","hints":"36","executionTime":2,"executionStatus":"27","data":"37"},{"startTime":1766772180863,"executionIndex":4,"source":"38","hints":"39","executionTime":3,"executionStatus":"27","data":"40"},{"startTime":1766772180866,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75","76","77","78","79","80","81","82","83","84","85"],"Get Messages",["86"],"Format Response",["87"],{"json":"88","pairedItem":"89"},{"json":"90","pairedItem":"91"},{"json":"90","pairedItem":"92"},{"json":"93","pairedItem":"94"},{"json":"95","pairedItem":"94"},{"json":"96","pairedItem":"94"},{"json":"97","pairedItem":"94"},{"json":"98","pairedItem":"94"},{"json":"99","pairedItem":"94"},{"json":"100","pairedItem":"94"},{"json":"101","pairedItem":"94"},{"json":"102","pairedItem":"94"},{"json":"103","pairedItem":"94"},{"json":"104","pairedItem":"94"},{"json":"105","pairedItem":"94"},{"json":"106"},{"json":"106","pairedItem":"107"},{"headers":"108","params":"109","query":"110","body":"111","webhookUrl":"112","executionMode":"113"},{"item":0},{"valid":true,"userId":1,"conversationId":"114"},{"item":0},{"item":0},{"message_id":1,"role":"115","content":"116","created_at":"117"},{"item":0},{"message_id":2,"role":"118","content":"119","created_at":"120"},{"message_id":3,"role":"115","content":"121","created_at":"122"},{"message_id":4,"role":"118","content":"123","created_at":"124"},{"message_id":5,"role":"115","content":"125","created_at":"126"},{"message_id":6,"role":"118","content":"127","created_at":"128"},{"message_id":27,"role":"115","content":"129","created_at":"130"},{"message_id":28,"role":"118","content":"131","created_at":"130"},{"message_id":29,"role":"115","content":"132","created_at":"133"},{"message_id":30,"role":"118","content":"134","created_at":"133"},{"message_id":31,"role":"115","content":"135","created_at":"136"},{"message_id":32,"role":"118","content":"137","created_at":"136"},{"success":true,"messages":"138"},{"item":0},{"host":"139","x-real-ip":"140","x-forwarded-for":"140","x-forwarded-proto":"141","connection":"142","sec-ch-ua-platform":"143","authorization":"144","user-agent":"145","accept":"146","sec-ch-ua":"147","dnt":"148","sec-ch-ua-mobile":"149","sec-fetch-site":"150","sec-fetch-mode":"151","sec-fetch-dest":"152","referer":"153","accept-encoding":"154","accept-language":"155","cookie":"156","sec-gpc":"148","if-none-match":"157"},{},{"conversationId":"114"},{},"http://localhost:5678/webhook/wibot/messages","production","550e8400-e29b-41d4-a716-446655440000","user","Bonjour WIBOT !","2025-12-24T07:42:15Z","assistant","Bonjour ! Je suis WIBOT, l'assistant IA de WIDIP. Comment puis-je t'aider aujourd'hui ?","2025-12-24T07:42:17Z","Peux-tu m'expliquer comment fonctionne PostgreSQL ?","2025-12-24T07:43:15Z","PostgreSQL est un systeme de gestion de base de donnees relationnelle (SGBDR) open source tres puissant.\\n\\n**Caracteristiques principales :**\\n- Support complet SQL\\n- Transactions ACID\\n- Extensions (comme pgcrypto pour le chiffrement)\\n- Excellent pour les charges de travail complexes\\n\\nC'est ce qu'on utilise chez WIDIP pour stocker les donnees WIBOT !","2025-12-24T07:43:20Z","Et comment faire un backup ?","2025-12-25T07:42:15Z","Pour faire un backup PostgreSQL, tu as plusieurs options :\\n\\n```bash\\n# Backup complet (dump SQL)\\npg_dump -U widip -d wibot > backup.sql\\n\\n# Backup compresse\\npg_dump -U widip -d wibot | gzip > backup.sql.gz\\n\\n# Restauration\\npsql -U widip -d wibot < backup.sql\\n```\\n\\nPour les backups automatiques, on peut utiliser un cron job ou un workflow n8n !","2025-12-25T07:42:18Z","salut","2025-12-26T17:16:30Z","Salut ! Comment puis-je vous aider aujourd'hui ?","ddadzax","2025-12-26T17:16:38Z","Bonjour ! Je ne suis pas sûr de comprendre votre demande. Pourriez-vous préciser ou reformuler votre question ? Je suis là pour vous aider avec les questions techniques ou toute autre demande liée à WIDIP.","hey","2025-12-26T17:28:13Z","Bonjour ! Comment puis-je vous aider aujourd'hui ?",["158","159","160","161","162","163","164","165","166","167","168","169"],"localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzAwODYsImV4cCI6MTc2Njg1NjQ4Nn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","W/\\"8c1-97WpuvK54GrQdO+AMWrIvvfcngA\\"",{"message_id":1,"role":"115","content":"116","created_at":"117"},{"message_id":2,"role":"118","content":"119","created_at":"120"},{"message_id":3,"role":"115","content":"121","created_at":"122"},{"message_id":4,"role":"118","content":"123","created_at":"124"},{"message_id":5,"role":"115","content":"125","created_at":"126"},{"message_id":6,"role":"118","content":"127","created_at":"128"},{"message_id":27,"role":"115","content":"129","created_at":"130"},{"message_id":28,"role":"118","content":"131","created_at":"130"},{"message_id":29,"role":"115","content":"132","created_at":"133"},{"message_id":30,"role":"118","content":"134","created_at":"133"},{"message_id":31,"role":"115","content":"135","created_at":"136"},{"message_id":32,"role":"118","content":"137","created_at":"136"}]
106	{"id":"msg5c740bd9db51","name":"WIBOT - Get Messages","active":true,"activeVersionId":"704bc444-e5e2-4901-9322-383bc1bd0434","isArchived":false,"createdAt":"2025-12-26T17:58:10.218Z","updatedAt":"2025-12-26T17:58:10.218Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/messages","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"webhook-messages","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,300],"webhookId":"wibot-messages"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst conversationId = $input.first().json.query.conversationId;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nif (!conversationId) {\\n  return [{ json: { valid: false, error: 'conversationId is required' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId, conversationId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"verify-jwt","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[470,300]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"if-jwt-valid","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[690,300]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-unauthorized","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[910,450]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  m.message_id,\\n  m.role,\\n  m.content,\\n  TO_CHAR(m.created_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as created_at\\nFROM messages m\\nJOIN conversations c ON m.conversation_id = c.conversation_id\\nWHERE m.conversation_id = '{{ $json.conversationId }}'::uuid\\n  AND c.user_id = {{ $json.userId }}\\nORDER BY m.created_at ASC;","options":{}},"id":"get-messages","name":"Get Messages","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[910,200],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats, retourner liste vide\\nif (!rows || rows.length === 0 || !rows[0].json.message_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      messages: []\\n    }\\n  }];\\n}\\n\\nconst messages = rows.map(row => ({\\n  message_id: row.json.message_id,\\n  role: row.json.role,\\n  content: row.json.content,\\n  created_at: row.json.created_at\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    messages\\n  }\\n}];","notice":""},"id":"format-response","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1130,200]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-success","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1350,200]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Messages","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Messages":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Messages":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766772182951,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766772182951,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766772182951,"executionIndex":1,"source":"29","hints":"30","executionTime":3,"executionStatus":"27","data":"31"},{"startTime":1766772182955,"executionIndex":2,"source":"32","hints":"33","executionTime":0,"executionStatus":"27","data":"34"},{"startTime":1766772182955,"executionIndex":3,"source":"35","hints":"36","executionTime":4,"executionStatus":"27","data":"37"},{"startTime":1766772182959,"executionIndex":4,"source":"38","hints":"39","executionTime":2,"executionStatus":"27","data":"40"},{"startTime":1766772182961,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75"],"Get Messages",["76"],"Format Response",["77"],{"json":"78","pairedItem":"79"},{"json":"80","pairedItem":"81"},{"json":"80","pairedItem":"82"},{"json":"83","pairedItem":"84"},{"json":"85","pairedItem":"84"},{"json":"86"},{"json":"86","pairedItem":"87"},{"headers":"88","params":"89","query":"90","body":"91","webhookUrl":"92","executionMode":"93"},{"item":0},{"valid":true,"userId":1,"conversationId":"94"},{"item":0},{"item":0},{"message_id":35,"role":"95","content":"96","created_at":"97"},{"item":0},{"message_id":36,"role":"98","content":"99","created_at":"97"},{"success":true,"messages":"100"},{"item":0},{"host":"101","x-real-ip":"102","x-forwarded-for":"102","x-forwarded-proto":"103","connection":"104","sec-ch-ua-platform":"105","authorization":"106","user-agent":"107","accept":"108","sec-ch-ua":"109","dnt":"110","sec-ch-ua-mobile":"111","sec-fetch-site":"112","sec-fetch-mode":"113","sec-fetch-dest":"114","referer":"115","accept-encoding":"116","accept-language":"117","cookie":"118","sec-gpc":"110"},{},{"conversationId":"94"},{},"http://localhost:5678/webhook/wibot/messages","production","419ba4c9-f14d-4af2-83b3-ba2399c17ffb","user","tu es tristes ?","2025-12-26T18:02:55Z","assistant","Non, je ne suis pas triste. En tant qu'IA, je n'ai pas de sentiments ou d'émotions. Mon rôle est de vous aider avec vos questions techniques et de fournir des réponses claires et professionnelles. Comment puis-je vous aider aujourd'hui ?",["119","120"],"localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzAwODYsImV4cCI6MTc2Njg1NjQ4Nn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D",{"message_id":35,"role":"95","content":"96","created_at":"97"},{"message_id":36,"role":"98","content":"99","created_at":"97"}]
107	{"id":"zZSHB9BHjR30ThPP","name":"WIBOT - Auth Login","active":true,"activeVersionId":"1e31f7d7-5e68-47eb-863c-91d1ec7b0819","isArchived":false,"createdAt":"2025-12-26T17:23:18.804Z","updatedAt":"2025-12-26T17:24:10.395Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"POST","path":"auth/login","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"c8898033-10a2-436a-915d-a01f108756c6","name":"Webhook Login","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-1104,208],"webhookId":"auth-login"},{"parameters":{"resource":"database","operation":"select","schema":"public","table":"users","returnAll":false,"limit":1,"where":{"values":[{"column":"username","condition":"equal","value":"={{ $json.body.username }}"},{"column":"is_active","condition":"equal","value":"true"}]},"combineConditions":"AND","sort":{},"options":{}},"id":"a2a158de-b676-468b-a23e-18466966d674","name":"Get User","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[-880,208],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-user-exists","leftValue":"={{ $json.user_id }}","rightValue":"","operator":{"type":"exists","operation":"exists"}}],"combinator":"and"},"options":{}},"id":"dd3f022d-09ed-47fe-ba59-73ae33165762","name":"User Exists?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-656,208]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const inputPassword = $('Webhook Login').first().json.body.password;\\nconst storedHash = $input.first().json.password_hash;\\nconst user = $input.first().json;\\n\\n// Comparaison simple du mot de passe\\nconst isValid = (inputPassword === storedHash);\\n\\nreturn [{ json: { isValid, user } }];","notice":""},"id":"bb41f913-1c3c-4afb-88a4-c46324c2b9ec","name":"Verify Password","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-password-valid","leftValue":"={{ $json.isValid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"73c0896e-95a9-4677-86c9-3398d7856fad","name":"Password Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const user = $input.first().json.user;\\n\\n// Fonction base64 encode compatible n8n\\nfunction toBase64(str) {\\n  return Buffer.from(str).toString('base64').replace(/=/g, '').replace(/\\\\+/g, '-').replace(/\\\\//g, '_');\\n}\\n\\nconst header = toBase64(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));\\n\\nconst payload = toBase64(JSON.stringify({\\n  userId: user.user_id,\\n  username: user.username,\\n  role: user.role,\\n  iat: Math.floor(Date.now() / 1000),\\n  exp: Math.floor(Date.now() / 1000) + (24 * 60 * 60)\\n}));\\n\\n// Signature simplifiée\\nconst signature = toBase64(header + payload + 'wibot_secret').substring(0, 43);\\n\\nconst token = `${header}.${payload}.${signature}`;\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    token,\\n    user: {\\n      id: user.user_id,\\n      username: user.username,\\n      role: user.role\\n    }\\n  }\\n}];","notice":""},"id":"56756190-1aeb-4413-946a-e2a7b4907e8e","name":"Generate JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[0,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"5e5d60cc-5fee-4f26-b838-71d66c7a885a","name":"Success Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[224,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"Invalid credentials\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"e90d3bbc-527a-4b00-b1dc-9bb17afa5966","name":"Invalid Password","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,208]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"User not found\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"8423d2d4-a607-49d0-a6d7-8730cf78fd86","name":"User Not Found","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[-448,304]}],"connections":{"Webhook Login":{"main":[[{"node":"Get User","type":"main","index":0}]]},"Get User":{"main":[[{"node":"User Exists?","type":"main","index":0}]]},"User Exists?":{"main":[[{"node":"Verify Password","type":"main","index":0}],[{"node":"User Not Found","type":"main","index":0}]]},"Verify Password":{"main":[[{"node":"Password Valid?","type":"main","index":0}]]},"Password Valid?":{"main":[[{"node":"Generate JWT","type":"main","index":0}],[{"node":"Invalid Password","type":"main","index":0}]]},"Generate JWT":{"main":[[{"node":"Success Response","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook Login":"12","Get User":"13","User Exists?":"14","Verify Password":"15","Password Valid?":"16","Generate JWT":"17","Success Response":"18"},"Success Response",{},[],{},{},{},{"version":1,"establishedAt":1766772216177,"source":"19"},["20"],["21"],["22"],["23"],["24"],["25"],["26"],"webhook",{"startTime":1766772216177,"executionIndex":0,"source":"27","hints":"28","executionTime":0,"executionStatus":"29","data":"30"},{"startTime":1766772216178,"executionIndex":1,"source":"31","hints":"32","executionTime":7,"executionStatus":"29","data":"33"},{"startTime":1766772216185,"executionIndex":2,"source":"34","hints":"35","executionTime":1,"executionStatus":"29","data":"36"},{"startTime":1766772216186,"executionIndex":3,"source":"37","hints":"38","executionTime":2,"executionStatus":"29","data":"39"},{"startTime":1766772216188,"executionIndex":4,"source":"40","hints":"41","executionTime":1,"executionStatus":"29","data":"42"},{"startTime":1766772216189,"executionIndex":5,"source":"43","hints":"44","executionTime":4,"executionStatus":"29","data":"45"},{"startTime":1766772216194,"executionIndex":6,"source":"46","hints":"47","executionTime":1,"executionStatus":"29","data":"48"},[],[],"success",{"main":"49"},["50"],[],{"main":"51"},["52"],[],{"main":"53"},["54"],["55"],{"main":"56"},["57"],[],{"main":"58"},["59"],["60"],{"main":"61"},["62"],[],{"main":"63"},["64"],{"previousNode":"65"},["66"],{"previousNode":"67"},["68","69"],{"previousNode":"70"},{"message":"71","location":"72"},["73"],{"previousNode":"74"},["75","76"],{"previousNode":"77"},{"message":"71","location":"72"},["78"],{"previousNode":"79"},["80"],["81"],"Webhook Login",["82"],"Get User",["83"],[],"User Exists?","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["84"],"Verify Password",["85"],[],"Password Valid?",["86"],"Generate JWT",["87"],{"json":"88","pairedItem":"89"},{"json":"90","pairedItem":"91"},{"json":"90","pairedItem":"92"},{"json":"93","pairedItem":"94"},{"json":"93","pairedItem":"95"},{"json":"96","pairedItem":"97"},{"json":"96","pairedItem":"98"},{"headers":"99","params":"100","query":"101","body":"102","webhookUrl":"103","executionMode":"104"},{"item":0},{"user_id":1,"username":"105","password_hash":"106","email":"107","role":"108","created_at":"109","is_active":true},{"item":0},{"item":0},{"isValid":true,"user":"110"},{"item":0},{"item":0},{"success":true,"token":"111","user":"112"},{"item":0},{"item":0},{"host":"113","x-real-ip":"114","x-forwarded-for":"114","x-forwarded-proto":"115","connection":"116","content-length":"117","sec-ch-ua-platform":"118","user-agent":"119","accept":"120","sec-ch-ua":"121","content-type":"122","dnt":"123","sec-ch-ua-mobile":"124","origin":"125","sec-fetch-site":"126","sec-fetch-mode":"127","sec-fetch-dest":"128","referer":"129","accept-encoding":"130","accept-language":"131","cookie":"132","sec-gpc":"123"},{},{},{"username":"105","password":"106"},"http://localhost:5678/webhook/auth/login","production","khora","test123","khora@widip.fr","admin","2025-12-26T06:42:15.244Z",{"user_id":1,"username":"105","password_hash":"106","email":"107","role":"108","created_at":"109","is_active":true},"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzIyMTYsImV4cCI6MTc2Njg1ODYxNn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh",{"id":1,"username":"105","role":"108"},"localhost","172.20.0.1","http","close","41","\\"Windows\\"","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","application/json","1","?0","http://localhost:5173","same-origin","cors","empty","http://localhost:5173/login","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D"]
109	{"id":"c8fbjjX9ObuzBE4b","name":"WIBOT - Get User Tokens","active":true,"activeVersionId":"62643582-5e10-4f85-9c6c-74a85d102e67","isArchived":false,"createdAt":"2025-12-26T17:24:01.471Z","updatedAt":"2025-12-26T17:24:05.529Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/user/tokens","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"8fcee23f-b3e4-4c28-ad04-4ba456f7752a","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-656,112],"webhookId":"wibot-user-tokens"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"d8de2cd5-94e4-49a5-a318-1ee1c389abd9","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"c9c309e4-53ba-46be-8960-13da82f4f5f7","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"83cd3ac8-fb46-4de5-a8ce-5d24be08334c","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  COALESCE(used_tokens, 0) as used_tokens,\\n  COALESCE(quota_tokens, 50000) as quota_tokens,\\n  COALESCE(quota_tokens, 50000) - COALESCE(used_tokens, 0) as tokens_remaining\\nFROM user_token_usage\\nWHERE user_id = {{ $json.userId }}\\n  AND month = DATE_TRUNC('month', CURRENT_DATE)\\nLIMIT 1;","options":{}},"id":"b35fa964-24c4-49ed-a3b6-7df917662ceb","name":"Get Token Usage","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[0,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\nconst jwtData = $('Verify JWT').first().json;\\n\\n// Si pas de donnees, l'utilisateur n'a pas encore utilise de tokens ce mois\\nif (!rows || rows.length === 0 || rows[0].json.tokens_remaining === undefined) {\\n  return [{\\n    json: {\\n      success: true,\\n      used_tokens: 0,\\n      quota_tokens: 50000,\\n      tokens_remaining: 50000\\n    }\\n  }];\\n}\\n\\nconst data = rows[0].json;\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    used_tokens: parseInt(data.used_tokens) || 0,\\n    quota_tokens: parseInt(data.quota_tokens) || 50000,\\n    tokens_remaining: parseInt(data.tokens_remaining) || 50000\\n  }\\n}];","notice":""},"id":"7d9b1764-6fed-49d3-957f-402aa7f05696","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"67daad4e-a2fe-4b36-b18c-065181b80de3","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[448,0]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Token Usage","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Token Usage":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Token Usage":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766772216249,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766772216249,"executionIndex":0,"source":"25","hints":"26","executionTime":1,"executionStatus":"27","data":"28"},{"startTime":1766772216250,"executionIndex":1,"source":"29","hints":"30","executionTime":3,"executionStatus":"27","data":"31"},{"startTime":1766772216254,"executionIndex":2,"source":"32","hints":"33","executionTime":1,"executionStatus":"27","data":"34"},{"startTime":1766772216255,"executionIndex":3,"source":"35","hints":"36","executionTime":3,"executionStatus":"27","data":"37"},{"startTime":1766772216258,"executionIndex":4,"source":"38","hints":"39","executionTime":2,"executionStatus":"27","data":"40"},{"startTime":1766772216261,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74"],"Get Token Usage",["75"],"Format Response",["76"],{"json":"77","pairedItem":"78"},{"json":"79","pairedItem":"80"},{"json":"79","pairedItem":"81"},{"json":"82","pairedItem":"83"},{"json":"84","pairedItem":"85"},{"json":"84","pairedItem":"86"},{"headers":"87","params":"88","query":"89","body":"90","webhookUrl":"91","executionMode":"92"},{"item":0},{"valid":true,"userId":1},{"item":0},{"item":0},{"used_tokens":"93","quota_tokens":"94","tokens_remaining":"95"},{"item":0},{"success":true,"used_tokens":14353,"quota_tokens":50000,"tokens_remaining":35647},{"item":0},{"item":0},{"host":"96","x-real-ip":"97","x-forwarded-for":"97","x-forwarded-proto":"98","connection":"99","sec-ch-ua-platform":"100","authorization":"101","user-agent":"102","accept":"103","sec-ch-ua":"104","dnt":"105","sec-ch-ua-mobile":"106","sec-fetch-site":"107","sec-fetch-mode":"108","sec-fetch-dest":"109","referer":"110","accept-encoding":"111","accept-language":"112","cookie":"113","sec-gpc":"105","if-none-match":"114"},{},{},{},"http://localhost:5678/webhook/wibot/user/tokens","production","14353","50000","35647","localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzIyMTYsImV4cCI6MTc2Njg1ODYxNn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","W/\\"52-bzbXh/RvEQA2yaKK8CkF6t5J3wM\\""]
108	{"id":"yPYTzGXVRP2JQxs8","name":"WIBOT - Get Conversations","active":true,"activeVersionId":"e1bae720-4a31-4afe-a595-4a35f7e26b0f","isArchived":false,"createdAt":"2025-12-26T17:23:46.197Z","updatedAt":"2025-12-26T17:24:07.735Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/conversations","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"c0f9fbaf-d0bb-4e86-92e9-c3e34e750679","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-656,112],"webhookId":"wibot-conversations"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"a5bd8ac1-82cc-4021-8420-752f46440f49","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"352ea961-e9a7-4651-acad-b594ba9f1c8c","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"9a0fd5d7-2e41-4111-b2b2-f84c1403ea28","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  c.conversation_id::text,\\n  c.title,\\n  TO_CHAR(c.updated_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as updated_at,\\n  COUNT(m.message_id)::integer as message_count\\nFROM conversations c\\nLEFT JOIN messages m ON c.conversation_id = m.conversation_id\\nWHERE c.user_id = {{ $json.userId }}\\nGROUP BY c.conversation_id, c.title, c.updated_at\\nORDER BY c.updated_at DESC\\nLIMIT 50;","options":{}},"id":"8fe150d4-0f4e-41ac-bd90-8978f31f4459","name":"Get Conversations","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[0,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats ou resultats vides\\nif (!rows || rows.length === 0 || !rows[0].json.conversation_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      conversations: []\\n    }\\n  }];\\n}\\n\\nconst conversations = rows.map(row => ({\\n  conversation_id: row.json.conversation_id,\\n  title: row.json.title || 'Nouvelle conversation',\\n  updated_at: row.json.updated_at,\\n  message_count: parseInt(row.json.message_count) || 0\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    conversations\\n  }\\n}];","notice":""},"id":"8d9137c5-9aa8-4938-961f-50bdbc93ee8f","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"463fcf83-1d8e-472a-94df-623b505f1a5d","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[448,0]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Conversations","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Conversations":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Conversations":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766772216243,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766772216243,"executionIndex":0,"source":"25","hints":"26","executionTime":1,"executionStatus":"27","data":"28"},{"startTime":1766772216244,"executionIndex":1,"source":"29","hints":"30","executionTime":4,"executionStatus":"27","data":"31"},{"startTime":1766772216248,"executionIndex":2,"source":"32","hints":"33","executionTime":0,"executionStatus":"27","data":"34"},{"startTime":1766772216248,"executionIndex":3,"source":"35","hints":"36","executionTime":23,"executionStatus":"27","data":"37"},{"startTime":1766772216271,"executionIndex":4,"source":"38","hints":"39","executionTime":4,"executionStatus":"27","data":"40"},{"startTime":1766772216275,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75","76","77"],"Get Conversations",["78"],"Format Response",["79"],{"json":"80","pairedItem":"81"},{"json":"82","pairedItem":"83"},{"json":"82","pairedItem":"84"},{"json":"85","pairedItem":"86"},{"json":"87","pairedItem":"86"},{"json":"88","pairedItem":"86"},{"json":"89","pairedItem":"86"},{"json":"90"},{"json":"90","pairedItem":"91"},{"headers":"92","params":"93","query":"94","body":"95","webhookUrl":"96","executionMode":"97"},{"item":0},{"valid":true,"userId":1},{"item":0},{"item":0},{"conversation_id":"98","title":"99","updated_at":"100","message_count":2},{"item":0},{"conversation_id":"101","title":"102","updated_at":"103","message_count":8},{"conversation_id":"104","title":"105","updated_at":"106","message_count":12},{"conversation_id":"107","title":"108","updated_at":"109","message_count":14},{"success":true,"conversations":"110"},{"item":0},{"host":"111","x-real-ip":"112","x-forwarded-for":"112","x-forwarded-proto":"113","connection":"114","sec-ch-ua-platform":"115","authorization":"116","user-agent":"117","accept":"118","sec-ch-ua":"119","dnt":"120","sec-ch-ua-mobile":"121","sec-fetch-site":"122","sec-fetch-mode":"123","sec-fetch-dest":"124","referer":"125","accept-encoding":"126","accept-language":"127","cookie":"128","sec-gpc":"120","if-none-match":"129"},{},{},{},"http://localhost:5678/webhook/wibot/conversations","production","419ba4c9-f14d-4af2-83b3-ba2399c17ffb","tu es tristes ?","2025-12-26T18:02:55Z","963eb9f1-fdcc-4cd5-918b-29fae40c17a0","quel est le chiffre important que je t'ai donné ?","2025-12-26T17:34:13Z","550e8400-e29b-41d4-a716-446655440000","Conversation de test","2025-12-26T17:28:13Z","3cc2c8db-afef-4637-accc-31d259f53857","saluty","2025-12-26T16:45:24Z",["130","131","132","133"],"localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzIyMTYsImV4cCI6MTc2Njg1ODYxNn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","W/\\"1e4-oCAPe6gog56nbHcwBhya3J1Oeb8\\"",{"conversation_id":"98","title":"99","updated_at":"100","message_count":2},{"conversation_id":"101","title":"102","updated_at":"103","message_count":8},{"conversation_id":"104","title":"105","updated_at":"106","message_count":12},{"conversation_id":"107","title":"108","updated_at":"109","message_count":14}]
110	{"id":"c8fbjjX9ObuzBE4b","name":"WIBOT - Get User Tokens","active":true,"activeVersionId":"62643582-5e10-4f85-9c6c-74a85d102e67","isArchived":false,"createdAt":"2025-12-26T17:24:01.471Z","updatedAt":"2025-12-26T17:24:05.529Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/user/tokens","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"8fcee23f-b3e4-4c28-ad04-4ba456f7752a","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-656,112],"webhookId":"wibot-user-tokens"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"d8de2cd5-94e4-49a5-a318-1ee1c389abd9","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"c9c309e4-53ba-46be-8960-13da82f4f5f7","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"83cd3ac8-fb46-4de5-a8ce-5d24be08334c","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  COALESCE(used_tokens, 0) as used_tokens,\\n  COALESCE(quota_tokens, 50000) as quota_tokens,\\n  COALESCE(quota_tokens, 50000) - COALESCE(used_tokens, 0) as tokens_remaining\\nFROM user_token_usage\\nWHERE user_id = {{ $json.userId }}\\n  AND month = DATE_TRUNC('month', CURRENT_DATE)\\nLIMIT 1;","options":{}},"id":"b35fa964-24c4-49ed-a3b6-7df917662ceb","name":"Get Token Usage","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[0,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\nconst jwtData = $('Verify JWT').first().json;\\n\\n// Si pas de donnees, l'utilisateur n'a pas encore utilise de tokens ce mois\\nif (!rows || rows.length === 0 || rows[0].json.tokens_remaining === undefined) {\\n  return [{\\n    json: {\\n      success: true,\\n      used_tokens: 0,\\n      quota_tokens: 50000,\\n      tokens_remaining: 50000\\n    }\\n  }];\\n}\\n\\nconst data = rows[0].json;\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    used_tokens: parseInt(data.used_tokens) || 0,\\n    quota_tokens: parseInt(data.quota_tokens) || 50000,\\n    tokens_remaining: parseInt(data.tokens_remaining) || 50000\\n  }\\n}];","notice":""},"id":"7d9b1764-6fed-49d3-957f-402aa7f05696","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"67daad4e-a2fe-4b36-b18c-065181b80de3","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[448,0]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Token Usage","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Token Usage":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Token Usage":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766772216297,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766772216297,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766772216297,"executionIndex":1,"source":"29","hints":"30","executionTime":3,"executionStatus":"27","data":"31"},{"startTime":1766772216300,"executionIndex":2,"source":"32","hints":"33","executionTime":0,"executionStatus":"27","data":"34"},{"startTime":1766772216300,"executionIndex":3,"source":"35","hints":"36","executionTime":3,"executionStatus":"27","data":"37"},{"startTime":1766772216303,"executionIndex":4,"source":"38","hints":"39","executionTime":3,"executionStatus":"27","data":"40"},{"startTime":1766772216306,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74"],"Get Token Usage",["75"],"Format Response",["76"],{"json":"77","pairedItem":"78"},{"json":"79","pairedItem":"80"},{"json":"79","pairedItem":"81"},{"json":"82","pairedItem":"83"},{"json":"84","pairedItem":"85"},{"json":"84","pairedItem":"86"},{"headers":"87","params":"88","query":"89","body":"90","webhookUrl":"91","executionMode":"92"},{"item":0},{"valid":true,"userId":1},{"item":0},{"item":0},{"used_tokens":"93","quota_tokens":"94","tokens_remaining":"95"},{"item":0},{"success":true,"used_tokens":14353,"quota_tokens":50000,"tokens_remaining":35647},{"item":0},{"item":0},{"host":"96","x-real-ip":"97","x-forwarded-for":"97","x-forwarded-proto":"98","connection":"99","sec-ch-ua-platform":"100","authorization":"101","user-agent":"102","accept":"103","sec-ch-ua":"104","dnt":"105","sec-ch-ua-mobile":"106","sec-fetch-site":"107","sec-fetch-mode":"108","sec-fetch-dest":"109","referer":"110","accept-encoding":"111","accept-language":"112","cookie":"113","sec-gpc":"105","if-none-match":"114"},{},{},{},"http://localhost:5678/webhook/wibot/user/tokens","production","14353","50000","35647","localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzIyMTYsImV4cCI6MTc2Njg1ODYxNn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","W/\\"52-eHX1zguHDxHiVPOLsHSEAK1e2d4\\""]
111	{"id":"yPYTzGXVRP2JQxs8","name":"WIBOT - Get Conversations","active":true,"activeVersionId":"e1bae720-4a31-4afe-a595-4a35f7e26b0f","isArchived":false,"createdAt":"2025-12-26T17:23:46.197Z","updatedAt":"2025-12-26T17:24:07.735Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/conversations","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"c0f9fbaf-d0bb-4e86-92e9-c3e34e750679","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-656,112],"webhookId":"wibot-conversations"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"a5bd8ac1-82cc-4021-8420-752f46440f49","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"352ea961-e9a7-4651-acad-b594ba9f1c8c","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"9a0fd5d7-2e41-4111-b2b2-f84c1403ea28","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  c.conversation_id::text,\\n  c.title,\\n  TO_CHAR(c.updated_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as updated_at,\\n  COUNT(m.message_id)::integer as message_count\\nFROM conversations c\\nLEFT JOIN messages m ON c.conversation_id = m.conversation_id\\nWHERE c.user_id = {{ $json.userId }}\\nGROUP BY c.conversation_id, c.title, c.updated_at\\nORDER BY c.updated_at DESC\\nLIMIT 50;","options":{}},"id":"8fe150d4-0f4e-41ac-bd90-8978f31f4459","name":"Get Conversations","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[0,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats ou resultats vides\\nif (!rows || rows.length === 0 || !rows[0].json.conversation_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      conversations: []\\n    }\\n  }];\\n}\\n\\nconst conversations = rows.map(row => ({\\n  conversation_id: row.json.conversation_id,\\n  title: row.json.title || 'Nouvelle conversation',\\n  updated_at: row.json.updated_at,\\n  message_count: parseInt(row.json.message_count) || 0\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    conversations\\n  }\\n}];","notice":""},"id":"8d9137c5-9aa8-4938-961f-50bdbc93ee8f","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"463fcf83-1d8e-472a-94df-623b505f1a5d","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[448,0]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Conversations","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Conversations":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Conversations":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766772216315,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766772216315,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766772216315,"executionIndex":1,"source":"29","hints":"30","executionTime":4,"executionStatus":"27","data":"31"},{"startTime":1766772216319,"executionIndex":2,"source":"32","hints":"33","executionTime":0,"executionStatus":"27","data":"34"},{"startTime":1766772216320,"executionIndex":3,"source":"35","hints":"36","executionTime":2,"executionStatus":"27","data":"37"},{"startTime":1766772216322,"executionIndex":4,"source":"38","hints":"39","executionTime":2,"executionStatus":"27","data":"40"},{"startTime":1766772216325,"executionIndex":5,"source":"41","hints":"42","executionTime":0,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75","76","77"],"Get Conversations",["78"],"Format Response",["79"],{"json":"80","pairedItem":"81"},{"json":"82","pairedItem":"83"},{"json":"82","pairedItem":"84"},{"json":"85","pairedItem":"86"},{"json":"87","pairedItem":"86"},{"json":"88","pairedItem":"86"},{"json":"89","pairedItem":"86"},{"json":"90"},{"json":"90","pairedItem":"91"},{"headers":"92","params":"93","query":"94","body":"95","webhookUrl":"96","executionMode":"97"},{"item":0},{"valid":true,"userId":1},{"item":0},{"item":0},{"conversation_id":"98","title":"99","updated_at":"100","message_count":2},{"item":0},{"conversation_id":"101","title":"102","updated_at":"103","message_count":8},{"conversation_id":"104","title":"105","updated_at":"106","message_count":12},{"conversation_id":"107","title":"108","updated_at":"109","message_count":14},{"success":true,"conversations":"110"},{"item":0},{"host":"111","x-real-ip":"112","x-forwarded-for":"112","x-forwarded-proto":"113","connection":"114","sec-ch-ua-platform":"115","authorization":"116","user-agent":"117","accept":"118","sec-ch-ua":"119","dnt":"120","sec-ch-ua-mobile":"121","sec-fetch-site":"122","sec-fetch-mode":"123","sec-fetch-dest":"124","referer":"125","accept-encoding":"126","accept-language":"127","cookie":"128","sec-gpc":"120","if-none-match":"129"},{},{},{},"http://localhost:5678/webhook/wibot/conversations","production","419ba4c9-f14d-4af2-83b3-ba2399c17ffb","tu es tristes ?","2025-12-26T18:02:55Z","963eb9f1-fdcc-4cd5-918b-29fae40c17a0","quel est le chiffre important que je t'ai donné ?","2025-12-26T17:34:13Z","550e8400-e29b-41d4-a716-446655440000","Conversation de test","2025-12-26T17:28:13Z","3cc2c8db-afef-4637-accc-31d259f53857","saluty","2025-12-26T16:45:24Z",["130","131","132","133"],"localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzIyMTYsImV4cCI6MTc2Njg1ODYxNn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","W/\\"26f-vT5fVP674oqMWVPWp39kPkaUWpU\\"",{"conversation_id":"98","title":"99","updated_at":"100","message_count":2},{"conversation_id":"101","title":"102","updated_at":"103","message_count":8},{"conversation_id":"104","title":"105","updated_at":"106","message_count":12},{"conversation_id":"107","title":"108","updated_at":"109","message_count":14}]
112	{"id":"msg5c740bd9db51","name":"WIBOT - Get Messages","active":true,"activeVersionId":"704bc444-e5e2-4901-9322-383bc1bd0434","isArchived":false,"createdAt":"2025-12-26T17:58:10.218Z","updatedAt":"2025-12-26T17:58:10.218Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/messages","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"webhook-messages","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,300],"webhookId":"wibot-messages"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst conversationId = $input.first().json.query.conversationId;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nif (!conversationId) {\\n  return [{ json: { valid: false, error: 'conversationId is required' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId, conversationId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"verify-jwt","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[470,300]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"if-jwt-valid","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[690,300]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-unauthorized","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[910,450]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  m.message_id,\\n  m.role,\\n  m.content,\\n  TO_CHAR(m.created_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as created_at\\nFROM messages m\\nJOIN conversations c ON m.conversation_id = c.conversation_id\\nWHERE m.conversation_id = '{{ $json.conversationId }}'::uuid\\n  AND c.user_id = {{ $json.userId }}\\nORDER BY m.created_at ASC;","options":{}},"id":"get-messages","name":"Get Messages","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[910,200],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats, retourner liste vide\\nif (!rows || rows.length === 0 || !rows[0].json.message_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      messages: []\\n    }\\n  }];\\n}\\n\\nconst messages = rows.map(row => ({\\n  message_id: row.json.message_id,\\n  role: row.json.role,\\n  content: row.json.content,\\n  created_at: row.json.created_at\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    messages\\n  }\\n}];","notice":""},"id":"format-response","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1130,200]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-success","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1350,200]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Messages","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Messages":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Messages":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766772216327,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766772216327,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766772216327,"executionIndex":1,"source":"29","hints":"30","executionTime":3,"executionStatus":"27","data":"31"},{"startTime":1766772216330,"executionIndex":2,"source":"32","hints":"33","executionTime":1,"executionStatus":"27","data":"34"},{"startTime":1766772216331,"executionIndex":3,"source":"35","hints":"36","executionTime":2,"executionStatus":"27","data":"37"},{"startTime":1766772216333,"executionIndex":4,"source":"38","hints":"39","executionTime":2,"executionStatus":"27","data":"40"},{"startTime":1766772216335,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75"],"Get Messages",["76"],"Format Response",["77"],{"json":"78","pairedItem":"79"},{"json":"80","pairedItem":"81"},{"json":"80","pairedItem":"82"},{"json":"83","pairedItem":"84"},{"json":"85","pairedItem":"84"},{"json":"86"},{"json":"86","pairedItem":"87"},{"headers":"88","params":"89","query":"90","body":"91","webhookUrl":"92","executionMode":"93"},{"item":0},{"valid":true,"userId":1,"conversationId":"94"},{"item":0},{"item":0},{"message_id":35,"role":"95","content":"96","created_at":"97"},{"item":0},{"message_id":36,"role":"98","content":"99","created_at":"97"},{"success":true,"messages":"100"},{"item":0},{"host":"101","x-real-ip":"102","x-forwarded-for":"102","x-forwarded-proto":"103","connection":"104","sec-ch-ua-platform":"105","authorization":"106","user-agent":"107","accept":"108","sec-ch-ua":"109","dnt":"110","sec-ch-ua-mobile":"111","sec-fetch-site":"112","sec-fetch-mode":"113","sec-fetch-dest":"114","referer":"115","accept-encoding":"116","accept-language":"117","cookie":"118","sec-gpc":"110","if-none-match":"119"},{},{"conversationId":"94"},{},"http://localhost:5678/webhook/wibot/messages","production","419ba4c9-f14d-4af2-83b3-ba2399c17ffb","user","tu es tristes ?","2025-12-26T18:02:55Z","assistant","Non, je ne suis pas triste. En tant qu'IA, je n'ai pas de sentiments ou d'émotions. Mon rôle est de vous aider avec vos questions techniques et de fournir des réponses claires et professionnelles. Comment puis-je vous aider aujourd'hui ?",["120","121"],"localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzIyMTYsImV4cCI6MTc2Njg1ODYxNn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","W/\\"1c3-FLRNx9lSWv1AwsfyAn02Yeb78cA\\"",{"message_id":35,"role":"95","content":"96","created_at":"97"},{"message_id":36,"role":"98","content":"99","created_at":"97"}]
113	{"id":"msg5c740bd9db51","name":"WIBOT - Get Messages","active":true,"activeVersionId":"704bc444-e5e2-4901-9322-383bc1bd0434","isArchived":false,"createdAt":"2025-12-26T17:58:10.218Z","updatedAt":"2025-12-26T17:58:10.218Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/messages","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"webhook-messages","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,300],"webhookId":"wibot-messages"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst conversationId = $input.first().json.query.conversationId;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nif (!conversationId) {\\n  return [{ json: { valid: false, error: 'conversationId is required' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId, conversationId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"verify-jwt","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[470,300]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"if-jwt-valid","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[690,300]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-unauthorized","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[910,450]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  m.message_id,\\n  m.role,\\n  m.content,\\n  TO_CHAR(m.created_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as created_at\\nFROM messages m\\nJOIN conversations c ON m.conversation_id = c.conversation_id\\nWHERE m.conversation_id = '{{ $json.conversationId }}'::uuid\\n  AND c.user_id = {{ $json.userId }}\\nORDER BY m.created_at ASC;","options":{}},"id":"get-messages","name":"Get Messages","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[910,200],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats, retourner liste vide\\nif (!rows || rows.length === 0 || !rows[0].json.message_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      messages: []\\n    }\\n  }];\\n}\\n\\nconst messages = rows.map(row => ({\\n  message_id: row.json.message_id,\\n  role: row.json.role,\\n  content: row.json.content,\\n  created_at: row.json.created_at\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    messages\\n  }\\n}];","notice":""},"id":"format-response","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1130,200]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-success","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1350,200]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Messages","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Messages":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Messages":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766772216355,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766772216355,"executionIndex":0,"source":"25","hints":"26","executionTime":1,"executionStatus":"27","data":"28"},{"startTime":1766772216356,"executionIndex":1,"source":"29","hints":"30","executionTime":2,"executionStatus":"27","data":"31"},{"startTime":1766772216359,"executionIndex":2,"source":"32","hints":"33","executionTime":0,"executionStatus":"27","data":"34"},{"startTime":1766772216359,"executionIndex":3,"source":"35","hints":"36","executionTime":2,"executionStatus":"27","data":"37"},{"startTime":1766772216361,"executionIndex":4,"source":"38","hints":"39","executionTime":2,"executionStatus":"27","data":"40"},{"startTime":1766772216363,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75"],"Get Messages",["76"],"Format Response",["77"],{"json":"78","pairedItem":"79"},{"json":"80","pairedItem":"81"},{"json":"80","pairedItem":"82"},{"json":"83","pairedItem":"84"},{"json":"85","pairedItem":"84"},{"json":"86"},{"json":"86","pairedItem":"87"},{"headers":"88","params":"89","query":"90","body":"91","webhookUrl":"92","executionMode":"93"},{"item":0},{"valid":true,"userId":1,"conversationId":"94"},{"item":0},{"item":0},{"message_id":35,"role":"95","content":"96","created_at":"97"},{"item":0},{"message_id":36,"role":"98","content":"99","created_at":"97"},{"success":true,"messages":"100"},{"item":0},{"host":"101","x-real-ip":"102","x-forwarded-for":"102","x-forwarded-proto":"103","connection":"104","sec-ch-ua-platform":"105","authorization":"106","user-agent":"107","accept":"108","sec-ch-ua":"109","dnt":"110","sec-ch-ua-mobile":"111","sec-fetch-site":"112","sec-fetch-mode":"113","sec-fetch-dest":"114","referer":"115","accept-encoding":"116","accept-language":"117","cookie":"118","sec-gpc":"110","if-none-match":"119"},{},{"conversationId":"94"},{},"http://localhost:5678/webhook/wibot/messages","production","419ba4c9-f14d-4af2-83b3-ba2399c17ffb","user","tu es tristes ?","2025-12-26T18:02:55Z","assistant","Non, je ne suis pas triste. En tant qu'IA, je n'ai pas de sentiments ou d'émotions. Mon rôle est de vous aider avec vos questions techniques et de fournir des réponses claires et professionnelles. Comment puis-je vous aider aujourd'hui ?",["120","121"],"localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzIyMTYsImV4cCI6MTc2Njg1ODYxNn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","W/\\"1c3-FLRNx9lSWv1AwsfyAn02Yeb78cA\\"",{"message_id":35,"role":"95","content":"96","created_at":"97"},{"message_id":36,"role":"98","content":"99","created_at":"97"}]
114	{"id":"msg5c740bd9db51","name":"WIBOT - Get Messages","active":true,"activeVersionId":"704bc444-e5e2-4901-9322-383bc1bd0434","isArchived":false,"createdAt":"2025-12-26T17:58:10.218Z","updatedAt":"2025-12-26T17:58:10.218Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/messages","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"webhook-messages","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,300],"webhookId":"wibot-messages"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst conversationId = $input.first().json.query.conversationId;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nif (!conversationId) {\\n  return [{ json: { valid: false, error: 'conversationId is required' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId, conversationId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"verify-jwt","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[470,300]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"if-jwt-valid","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[690,300]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-unauthorized","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[910,450]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  m.message_id,\\n  m.role,\\n  m.content,\\n  TO_CHAR(m.created_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as created_at\\nFROM messages m\\nJOIN conversations c ON m.conversation_id = c.conversation_id\\nWHERE m.conversation_id = '{{ $json.conversationId }}'::uuid\\n  AND c.user_id = {{ $json.userId }}\\nORDER BY m.created_at ASC;","options":{}},"id":"get-messages","name":"Get Messages","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[910,200],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats, retourner liste vide\\nif (!rows || rows.length === 0 || !rows[0].json.message_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      messages: []\\n    }\\n  }];\\n}\\n\\nconst messages = rows.map(row => ({\\n  message_id: row.json.message_id,\\n  role: row.json.role,\\n  content: row.json.content,\\n  created_at: row.json.created_at\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    messages\\n  }\\n}];","notice":""},"id":"format-response","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1130,200]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-success","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1350,200]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Messages","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Messages":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Messages":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766772217975,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766772217975,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766772217975,"executionIndex":1,"source":"29","hints":"30","executionTime":3,"executionStatus":"27","data":"31"},{"startTime":1766772217978,"executionIndex":2,"source":"32","hints":"33","executionTime":0,"executionStatus":"27","data":"34"},{"startTime":1766772217979,"executionIndex":3,"source":"35","hints":"36","executionTime":2,"executionStatus":"27","data":"37"},{"startTime":1766772217981,"executionIndex":4,"source":"38","hints":"39","executionTime":2,"executionStatus":"27","data":"40"},{"startTime":1766772217983,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75","76","77","78","79","80","81"],"Get Messages",["82"],"Format Response",["83"],{"json":"84","pairedItem":"85"},{"json":"86","pairedItem":"87"},{"json":"86","pairedItem":"88"},{"json":"89","pairedItem":"90"},{"json":"91","pairedItem":"90"},{"json":"92","pairedItem":"90"},{"json":"93","pairedItem":"90"},{"json":"94","pairedItem":"90"},{"json":"95","pairedItem":"90"},{"json":"96","pairedItem":"90"},{"json":"97","pairedItem":"90"},{"json":"98"},{"json":"98","pairedItem":"99"},{"headers":"100","params":"101","query":"102","body":"103","webhookUrl":"104","executionMode":"105"},{"item":0},{"valid":true,"userId":1,"conversationId":"106"},{"item":0},{"item":0},{"message_id":21,"role":"107","content":"108","created_at":"109"},{"item":0},{"message_id":22,"role":"110","content":"111","created_at":"109"},{"message_id":23,"role":"107","content":"112","created_at":"113"},{"message_id":24,"role":"110","content":"114","created_at":"113"},{"message_id":25,"role":"107","content":"112","created_at":"115"},{"message_id":26,"role":"110","content":"116","created_at":"115"},{"message_id":33,"role":"107","content":"117","created_at":"118"},{"message_id":34,"role":"110","content":"119","created_at":"118"},{"success":true,"messages":"120"},{"item":0},{"host":"121","x-real-ip":"122","x-forwarded-for":"122","x-forwarded-proto":"123","connection":"124","sec-ch-ua-platform":"125","authorization":"126","user-agent":"127","accept":"128","sec-ch-ua":"129","dnt":"130","sec-ch-ua-mobile":"131","sec-fetch-site":"132","sec-fetch-mode":"133","sec-fetch-dest":"134","referer":"135","accept-encoding":"136","accept-language":"137","cookie":"138","sec-gpc":"130","if-none-match":"139"},{},{"conversationId":"106"},{},"http://localhost:5678/webhook/wibot/messages","production","963eb9f1-fdcc-4cd5-918b-29fae40c17a0","user","quel est le chiffre important que je t'ai donné ?","2025-12-26T16:45:37Z","assistant","Je n'ai pas de mémoire persistante entre nos interactions, donc je ne peux pas me souvenir des informations partagées lors de nos précédentes conversations. Si vous me donnez à nouveau le chiffre important, je serai ravi de vous aider avec celui-ci.\\n\\nN'hésitez pas à me le communiquer !","salut","2025-12-26T17:13:49Z","Salut ! Comment puis-je vous aider aujourd'hui ? 😊","2025-12-26T17:14:33Z","Bonjour ! Comment puis-je vous aider aujourd'hui ? 😊","dsf ça va ?","2025-12-26T17:34:13Z","Bonjour ! Je vais très bien, merci de demander. 😊\\n\\nComment puis-je vous aider aujourd'hui ?",["140","141","142","143","144","145","146","147"],"localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzIyMTYsImV4cCI6MTc2Njg1ODYxNn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","W/\\"4f5-iX7OrMLhqWRZ+Pgvd44GsjyMq3A\\"",{"message_id":21,"role":"107","content":"108","created_at":"109"},{"message_id":22,"role":"110","content":"111","created_at":"109"},{"message_id":23,"role":"107","content":"112","created_at":"113"},{"message_id":24,"role":"110","content":"114","created_at":"113"},{"message_id":25,"role":"107","content":"112","created_at":"115"},{"message_id":26,"role":"110","content":"116","created_at":"115"},{"message_id":33,"role":"107","content":"117","created_at":"118"},{"message_id":34,"role":"110","content":"119","created_at":"118"}]
116	{"id":"msg5c740bd9db51","name":"WIBOT - Get Messages","active":true,"activeVersionId":"704bc444-e5e2-4901-9322-383bc1bd0434","isArchived":false,"createdAt":"2025-12-26T17:58:10.218Z","updatedAt":"2025-12-26T17:58:10.218Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/messages","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"webhook-messages","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,300],"webhookId":"wibot-messages"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst conversationId = $input.first().json.query.conversationId;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nif (!conversationId) {\\n  return [{ json: { valid: false, error: 'conversationId is required' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId, conversationId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"verify-jwt","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[470,300]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"if-jwt-valid","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[690,300]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-unauthorized","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[910,450]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  m.message_id,\\n  m.role,\\n  m.content,\\n  TO_CHAR(m.created_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as created_at\\nFROM messages m\\nJOIN conversations c ON m.conversation_id = c.conversation_id\\nWHERE m.conversation_id = '{{ $json.conversationId }}'::uuid\\n  AND c.user_id = {{ $json.userId }}\\nORDER BY m.created_at ASC;","options":{}},"id":"get-messages","name":"Get Messages","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[910,200],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats, retourner liste vide\\nif (!rows || rows.length === 0 || !rows[0].json.message_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      messages: []\\n    }\\n  }];\\n}\\n\\nconst messages = rows.map(row => ({\\n  message_id: row.json.message_id,\\n  role: row.json.role,\\n  content: row.json.content,\\n  created_at: row.json.created_at\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    messages\\n  }\\n}];","notice":""},"id":"format-response","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1130,200]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-success","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1350,200]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Messages","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Messages":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Messages":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766772218773,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766772218773,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766772218774,"executionIndex":1,"source":"29","hints":"30","executionTime":2,"executionStatus":"27","data":"31"},{"startTime":1766772218776,"executionIndex":2,"source":"32","hints":"33","executionTime":1,"executionStatus":"27","data":"34"},{"startTime":1766772218777,"executionIndex":3,"source":"35","hints":"36","executionTime":2,"executionStatus":"27","data":"37"},{"startTime":1766772218780,"executionIndex":4,"source":"38","hints":"39","executionTime":2,"executionStatus":"27","data":"40"},{"startTime":1766772218782,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75","76","77","78","79","80","81","82","83","84","85","86","87"],"Get Messages",["88"],"Format Response",["89"],{"json":"90","pairedItem":"91"},{"json":"92","pairedItem":"93"},{"json":"92","pairedItem":"94"},{"json":"95","pairedItem":"96"},{"json":"97","pairedItem":"96"},{"json":"98","pairedItem":"96"},{"json":"99","pairedItem":"96"},{"json":"100","pairedItem":"96"},{"json":"101","pairedItem":"96"},{"json":"102","pairedItem":"96"},{"json":"103","pairedItem":"96"},{"json":"104","pairedItem":"96"},{"json":"105","pairedItem":"96"},{"json":"106","pairedItem":"96"},{"json":"107","pairedItem":"96"},{"json":"108","pairedItem":"96"},{"json":"109","pairedItem":"96"},{"json":"110"},{"json":"110","pairedItem":"111"},{"headers":"112","params":"113","query":"114","body":"115","webhookUrl":"116","executionMode":"117"},{"item":0},{"valid":true,"userId":1,"conversationId":"118"},{"item":0},{"item":0},{"message_id":7,"role":"119","content":"120","created_at":"121"},{"item":0},{"message_id":8,"role":"122","content":"123","created_at":"121"},{"message_id":9,"role":"119","content":"124","created_at":"125"},{"message_id":10,"role":"122","content":"126","created_at":"125"},{"message_id":11,"role":"119","content":"127","created_at":"128"},{"message_id":12,"role":"122","content":"129","created_at":"128"},{"message_id":13,"role":"119","content":"130","created_at":"131"},{"message_id":14,"role":"122","content":"132","created_at":"131"},{"message_id":15,"role":"119","content":"133","created_at":"134"},{"message_id":16,"role":"122","content":"135","created_at":"134"},{"message_id":17,"role":"119","content":"136","created_at":"137"},{"message_id":18,"role":"122","content":"138","created_at":"137"},{"message_id":19,"role":"119","content":"139","created_at":"140"},{"message_id":20,"role":"122","content":"141","created_at":"140"},{"success":true,"messages":"142"},{"item":0},{"host":"143","x-real-ip":"144","x-forwarded-for":"144","x-forwarded-proto":"145","connection":"146","sec-ch-ua-platform":"147","authorization":"148","user-agent":"149","accept":"150","sec-ch-ua":"151","dnt":"152","sec-ch-ua-mobile":"153","sec-fetch-site":"154","sec-fetch-mode":"155","sec-fetch-dest":"156","referer":"157","accept-encoding":"158","accept-language":"159","cookie":"160","sec-gpc":"152","if-none-match":"161"},{},{"conversationId":"118"},{},"http://localhost:5678/webhook/wibot/messages","production","3cc2c8db-afef-4637-accc-31d259f53857","user","saluty","2025-12-26T16:43:14Z","assistant","Bonjour ! Comment puis-je vous aider aujourd'hui ?","tout va bien ?","2025-12-26T16:43:24Z","Tout va très bien, merci de demander ! Je suis prêt à vous aider avec vos questions techniques. Comment puis-je vous assister aujourd'hui ?","genere un max de text je test la conso token","2025-12-26T16:43:40Z","Je comprends que vous souhaitez tester la consommation de tokens. Voici un texte plus long pour vous aider dans votre test :\\n\\n---\\n\\nChez WIDIP, nous sommes une entreprise française de services informatiques spécialisée dans l'accompagnement des entreprises dans leur transformation numérique. Notre mission est de fournir des solutions technologiques innovantes et sur mesure pour répondre aux besoins spécifiques de nos clients.\\n\\nNous offrons une large gamme de services, allant du développement de logiciels sur mesure à l'infogérance, en passant par la cybersécurité et le cloud computing. Notre équipe d'experts est composée de professionnels qualifiés et passionnés, toujours prêts à relever les défis technologiques les plus complexes.\\n\\nChez WIDIP, nous croyons en l'importance de la collaboration et de la communication. Nous travaillons en étroite collaboration avec nos clients pour comprendre leurs besoins et leurs attentes, et nous nous engageons à fournir des solutions qui non seulement répondent à ces besoins, mais qui les dépassent.\\n\\nNous sommes également convaincus que la formation et le développement des compétences sont essentiels pour rester à la pointe de la technologie. C'est pourquoi nous investissons continuellement dans la formation de nos employés et dans l'acquisition de nouvelles compétences.\\n\\nEn choisissant WIDIP, vous bénéficiez de notre expertise, de notre engagement et de notre passion pour la technologie. Nous sommes là pour vous accompagner à chaque étape de votre transformation numérique, en vous fournissant des solutions qui vous permettent de tirer le meilleur parti de la technologie.\\n\\nSi vous avez des questions ou si vous souhaitez en savoir plus sur nos services, n'hésitez pas à nous contacter. Nous serons ravis de vous aider.\\n\\n---\\n\\nJ'espère que ce texte répond à vos besoins pour le test de consommation de tokens. Si vous avez d'autres questions ou besoin de plus d'informations, n'hésitez pas à me le faire savoir !","encore","2025-12-26T16:43:51Z","Bien sûr ! Voici un texte encore plus long pour votre test de consommation de tokens :\\n\\n---\\n\\nChez WIDIP, nous sommes une entreprise française de services informatiques spécialisée dans l'accompagnement des entreprises dans leur transformation numérique. Notre mission est de fournir des solutions technologiques innovantes et sur mesure pour répondre aux besoins spécifiques de nos clients.\\n\\nNous offrons une large gamme de services, allant du développement de logiciels sur mesure à l'infogérance, en passant par la cybersécurité et le cloud computing. Notre équipe d'experts est composée de professionnels qualifiés et passionnés, toujours prêts à relever les défis technologiques les plus complexes.\\n\\nChez WIDIP, nous croyons en l'importance de la collaboration et de la communication. Nous travaillons en étroite collaboration avec nos clients pour comprendre leurs besoins et leurs attentes, et nous nous engageons à fournir des solutions qui non seulement répondent à ces besoins, mais qui les dépassent.\\n\\nNous sommes également convaincus que la formation et le développement des compétences sont essentiels pour rester à la pointe de la technologie. C'est pourquoi nous investissons continuellement dans la formation de nos employés et dans l'acquisition de nouvelles compétences.\\n\\nEn choisissant WIDIP, vous bénéficiez de notre expertise, de notre engagement et de notre passion pour la technologie. Nous sommes là pour vous accompagner à chaque étape de votre transformation numérique, en vous fournissant des solutions qui vous permettent de tirer le meilleur parti de la technologie.\\n\\nSi vous avez des questions ou si vous souhaitez en savoir plus sur nos services, n'hésitez pas à nous contacter. Nous serons ravis de vous aider.\\n\\n---\\n\\nVoici un exemple de code en Python pour illustrer nos compétences en développement de logiciels :\\n\\n```python\\n# Exemple de code Python pour calculer la factorielle d'un nombre\\n\\ndef factorielle(n):\\n    if n == 0:\\n        return 1\\n    else:\\n        return n * factorielle(n - 1)\\n\\n# Exemple d'utilisation\\nnombre = 5\\nresultat = factorielle(nombre)\\nprint(f\\"La factorielle de {nombre} est {resultat}\\")\\n```\\n\\nChez WIDIP, nous utilisons des technologies de pointe pour développer des solutions robustes et évolutives. Nos développeurs sont expérimentés dans divers langages de programmation, tels que Python, Java, C++, et bien d'autres.\\n\\nNous mettons également un point d'honneur à suivre les meilleures pratiques en matière de développement logiciel, telles que la programmation orientée objet, les tests unitaires, et la documentation du code. Nous croyons que ces pratiques sont essentielles pour garantir la qualité et la maintenabilité de nos solutions.\\n\\nEn plus du développement de logiciels, nous offrons également des services d'infogérance pour aider nos clients à gérer leurs infrastructures informatiques. Nos experts en infogérance peuvent vous aider à optimiser vos systèmes, à améliorer leur sécurité, et à assurer leur disponibilité.\\n\\nNous proposons également des services de cybersécurité pour protéger vos données et vos systèmes contre les cybermenaces. Nos experts en cybersécurité peuvent vous aider à mettre en place des mesures de sécurité efficaces, à effectuer des audits de sécurité, et à répondre aux incidents de sécurité.\\n\\nEnfin, nous offrons des services de cloud computing pour vous aider à tirer parti des avantages du cloud. Nos experts en cloud computing peuvent vous aider à migrer vers le cloud, à optimiser vos coûts, et à tirer parti des fonctionnalités avancées des plateformes cloud.\\n\\nSi vous avez des questions ou si vous souhaitez en savoir plus sur nos services, n'hésitez pas à nous contacter. Nous serons ravis de vous aider.\\n\\n---\\n\\nJ'espère que ce texte supplémentaire répond à vos besoins pour le test de consommation de tokens. Si vous avez d'autres questions ou besoin de plus d'informations, n'hésitez pas à me le faire savoir !","hey !","2025-12-26T16:44:56Z","Bonjour ! Comment puis-je vous aider aujourd'hui ? 😊","je vais te donner un chiffre important tu vas le retenir , tu es pret ?","2025-12-26T16:45:18Z","Je suis prêt ! Donnez-moi le chiffre important, et je le retiendrai pour vous.","1996","2025-12-26T16:45:24Z","J'ai retenu le chiffre **1996**. Comment puis-je vous aider avec cette information ?",["162","163","164","165","166","167","168","169","170","171","172","173","174","175"],"localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzIyMTYsImV4cCI6MTc2Njg1ODYxNn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","W/\\"1eab-+F60koe1ruhtzP9joS1/4+QB/b4\\"",{"message_id":7,"role":"119","content":"120","created_at":"121"},{"message_id":8,"role":"122","content":"123","created_at":"121"},{"message_id":9,"role":"119","content":"124","created_at":"125"},{"message_id":10,"role":"122","content":"126","created_at":"125"},{"message_id":11,"role":"119","content":"127","created_at":"128"},{"message_id":12,"role":"122","content":"129","created_at":"128"},{"message_id":13,"role":"119","content":"130","created_at":"131"},{"message_id":14,"role":"122","content":"132","created_at":"131"},{"message_id":15,"role":"119","content":"133","created_at":"134"},{"message_id":16,"role":"122","content":"135","created_at":"134"},{"message_id":17,"role":"119","content":"136","created_at":"137"},{"message_id":18,"role":"122","content":"138","created_at":"137"},{"message_id":19,"role":"119","content":"139","created_at":"140"},{"message_id":20,"role":"122","content":"141","created_at":"140"}]
115	{"id":"msg5c740bd9db51","name":"WIBOT - Get Messages","active":true,"activeVersionId":"704bc444-e5e2-4901-9322-383bc1bd0434","isArchived":false,"createdAt":"2025-12-26T17:58:10.218Z","updatedAt":"2025-12-26T17:58:10.218Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/messages","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"webhook-messages","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,300],"webhookId":"wibot-messages"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst conversationId = $input.first().json.query.conversationId;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nif (!conversationId) {\\n  return [{ json: { valid: false, error: 'conversationId is required' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId, conversationId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"verify-jwt","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[470,300]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"if-jwt-valid","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[690,300]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-unauthorized","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[910,450]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  m.message_id,\\n  m.role,\\n  m.content,\\n  TO_CHAR(m.created_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as created_at\\nFROM messages m\\nJOIN conversations c ON m.conversation_id = c.conversation_id\\nWHERE m.conversation_id = '{{ $json.conversationId }}'::uuid\\n  AND c.user_id = {{ $json.userId }}\\nORDER BY m.created_at ASC;","options":{}},"id":"get-messages","name":"Get Messages","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[910,200],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats, retourner liste vide\\nif (!rows || rows.length === 0 || !rows[0].json.message_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      messages: []\\n    }\\n  }];\\n}\\n\\nconst messages = rows.map(row => ({\\n  message_id: row.json.message_id,\\n  role: row.json.role,\\n  content: row.json.content,\\n  created_at: row.json.created_at\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    messages\\n  }\\n}];","notice":""},"id":"format-response","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1130,200]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-success","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1350,200]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Messages","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Messages":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Messages":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766772218418,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766772218418,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766772218418,"executionIndex":1,"source":"29","hints":"30","executionTime":3,"executionStatus":"27","data":"31"},{"startTime":1766772218421,"executionIndex":2,"source":"32","hints":"33","executionTime":0,"executionStatus":"27","data":"34"},{"startTime":1766772218421,"executionIndex":3,"source":"35","hints":"36","executionTime":3,"executionStatus":"27","data":"37"},{"startTime":1766772218424,"executionIndex":4,"source":"38","hints":"39","executionTime":2,"executionStatus":"27","data":"40"},{"startTime":1766772218426,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75","76","77","78","79","80","81","82","83","84","85"],"Get Messages",["86"],"Format Response",["87"],{"json":"88","pairedItem":"89"},{"json":"90","pairedItem":"91"},{"json":"90","pairedItem":"92"},{"json":"93","pairedItem":"94"},{"json":"95","pairedItem":"94"},{"json":"96","pairedItem":"94"},{"json":"97","pairedItem":"94"},{"json":"98","pairedItem":"94"},{"json":"99","pairedItem":"94"},{"json":"100","pairedItem":"94"},{"json":"101","pairedItem":"94"},{"json":"102","pairedItem":"94"},{"json":"103","pairedItem":"94"},{"json":"104","pairedItem":"94"},{"json":"105","pairedItem":"94"},{"json":"106"},{"json":"106","pairedItem":"107"},{"headers":"108","params":"109","query":"110","body":"111","webhookUrl":"112","executionMode":"113"},{"item":0},{"valid":true,"userId":1,"conversationId":"114"},{"item":0},{"item":0},{"message_id":1,"role":"115","content":"116","created_at":"117"},{"item":0},{"message_id":2,"role":"118","content":"119","created_at":"120"},{"message_id":3,"role":"115","content":"121","created_at":"122"},{"message_id":4,"role":"118","content":"123","created_at":"124"},{"message_id":5,"role":"115","content":"125","created_at":"126"},{"message_id":6,"role":"118","content":"127","created_at":"128"},{"message_id":27,"role":"115","content":"129","created_at":"130"},{"message_id":28,"role":"118","content":"131","created_at":"130"},{"message_id":29,"role":"115","content":"132","created_at":"133"},{"message_id":30,"role":"118","content":"134","created_at":"133"},{"message_id":31,"role":"115","content":"135","created_at":"136"},{"message_id":32,"role":"118","content":"137","created_at":"136"},{"success":true,"messages":"138"},{"item":0},{"host":"139","x-real-ip":"140","x-forwarded-for":"140","x-forwarded-proto":"141","connection":"142","sec-ch-ua-platform":"143","authorization":"144","user-agent":"145","accept":"146","sec-ch-ua":"147","dnt":"148","sec-ch-ua-mobile":"149","sec-fetch-site":"150","sec-fetch-mode":"151","sec-fetch-dest":"152","referer":"153","accept-encoding":"154","accept-language":"155","cookie":"156","sec-gpc":"148","if-none-match":"157"},{},{"conversationId":"114"},{},"http://localhost:5678/webhook/wibot/messages","production","550e8400-e29b-41d4-a716-446655440000","user","Bonjour WIBOT !","2025-12-24T07:42:15Z","assistant","Bonjour ! Je suis WIBOT, l'assistant IA de WIDIP. Comment puis-je t'aider aujourd'hui ?","2025-12-24T07:42:17Z","Peux-tu m'expliquer comment fonctionne PostgreSQL ?","2025-12-24T07:43:15Z","PostgreSQL est un systeme de gestion de base de donnees relationnelle (SGBDR) open source tres puissant.\\n\\n**Caracteristiques principales :**\\n- Support complet SQL\\n- Transactions ACID\\n- Extensions (comme pgcrypto pour le chiffrement)\\n- Excellent pour les charges de travail complexes\\n\\nC'est ce qu'on utilise chez WIDIP pour stocker les donnees WIBOT !","2025-12-24T07:43:20Z","Et comment faire un backup ?","2025-12-25T07:42:15Z","Pour faire un backup PostgreSQL, tu as plusieurs options :\\n\\n```bash\\n# Backup complet (dump SQL)\\npg_dump -U widip -d wibot > backup.sql\\n\\n# Backup compresse\\npg_dump -U widip -d wibot | gzip > backup.sql.gz\\n\\n# Restauration\\npsql -U widip -d wibot < backup.sql\\n```\\n\\nPour les backups automatiques, on peut utiliser un cron job ou un workflow n8n !","2025-12-25T07:42:18Z","salut","2025-12-26T17:16:30Z","Salut ! Comment puis-je vous aider aujourd'hui ?","ddadzax","2025-12-26T17:16:38Z","Bonjour ! Je ne suis pas sûr de comprendre votre demande. Pourriez-vous préciser ou reformuler votre question ? Je suis là pour vous aider avec les questions techniques ou toute autre demande liée à WIDIP.","hey","2025-12-26T17:28:13Z","Bonjour ! Comment puis-je vous aider aujourd'hui ?",["158","159","160","161","162","163","164","165","166","167","168","169"],"localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzIyMTYsImV4cCI6MTc2Njg1ODYxNn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","W/\\"8c1-97WpuvK54GrQdO+AMWrIvvfcngA\\"",{"message_id":1,"role":"115","content":"116","created_at":"117"},{"message_id":2,"role":"118","content":"119","created_at":"120"},{"message_id":3,"role":"115","content":"121","created_at":"122"},{"message_id":4,"role":"118","content":"123","created_at":"124"},{"message_id":5,"role":"115","content":"125","created_at":"126"},{"message_id":6,"role":"118","content":"127","created_at":"128"},{"message_id":27,"role":"115","content":"129","created_at":"130"},{"message_id":28,"role":"118","content":"131","created_at":"130"},{"message_id":29,"role":"115","content":"132","created_at":"133"},{"message_id":30,"role":"118","content":"134","created_at":"133"},{"message_id":31,"role":"115","content":"135","created_at":"136"},{"message_id":32,"role":"118","content":"137","created_at":"136"}]
118	{"id":"c8fbjjX9ObuzBE4b","name":"WIBOT - Get User Tokens","active":true,"activeVersionId":"62643582-5e10-4f85-9c6c-74a85d102e67","isArchived":false,"createdAt":"2025-12-26T17:24:01.471Z","updatedAt":"2025-12-26T17:24:05.529Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/user/tokens","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"8fcee23f-b3e4-4c28-ad04-4ba456f7752a","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-656,112],"webhookId":"wibot-user-tokens"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"d8de2cd5-94e4-49a5-a318-1ee1c389abd9","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"c9c309e4-53ba-46be-8960-13da82f4f5f7","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"83cd3ac8-fb46-4de5-a8ce-5d24be08334c","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  COALESCE(used_tokens, 0) as used_tokens,\\n  COALESCE(quota_tokens, 50000) as quota_tokens,\\n  COALESCE(quota_tokens, 50000) - COALESCE(used_tokens, 0) as tokens_remaining\\nFROM user_token_usage\\nWHERE user_id = {{ $json.userId }}\\n  AND month = DATE_TRUNC('month', CURRENT_DATE)\\nLIMIT 1;","options":{}},"id":"b35fa964-24c4-49ed-a3b6-7df917662ceb","name":"Get Token Usage","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[0,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\nconst jwtData = $('Verify JWT').first().json;\\n\\n// Si pas de donnees, l'utilisateur n'a pas encore utilise de tokens ce mois\\nif (!rows || rows.length === 0 || rows[0].json.tokens_remaining === undefined) {\\n  return [{\\n    json: {\\n      success: true,\\n      used_tokens: 0,\\n      quota_tokens: 50000,\\n      tokens_remaining: 50000\\n    }\\n  }];\\n}\\n\\nconst data = rows[0].json;\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    used_tokens: parseInt(data.used_tokens) || 0,\\n    quota_tokens: parseInt(data.quota_tokens) || 50000,\\n    tokens_remaining: parseInt(data.tokens_remaining) || 50000\\n  }\\n}];","notice":""},"id":"7d9b1764-6fed-49d3-957f-402aa7f05696","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"67daad4e-a2fe-4b36-b18c-065181b80de3","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[448,0]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Token Usage","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Token Usage":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Token Usage":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766786348278,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766786348278,"executionIndex":0,"source":"25","hints":"26","executionTime":1,"executionStatus":"27","data":"28"},{"startTime":1766786348279,"executionIndex":1,"source":"29","hints":"30","executionTime":2,"executionStatus":"27","data":"31"},{"startTime":1766786348281,"executionIndex":2,"source":"32","hints":"33","executionTime":1,"executionStatus":"27","data":"34"},{"startTime":1766786348282,"executionIndex":3,"source":"35","hints":"36","executionTime":14,"executionStatus":"27","data":"37"},{"startTime":1766786348296,"executionIndex":4,"source":"38","hints":"39","executionTime":2,"executionStatus":"27","data":"40"},{"startTime":1766786348298,"executionIndex":5,"source":"41","hints":"42","executionTime":2,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74"],"Get Token Usage",["75"],"Format Response",["76"],{"json":"77","pairedItem":"78"},{"json":"79","pairedItem":"80"},{"json":"79","pairedItem":"81"},{"json":"82","pairedItem":"83"},{"json":"84","pairedItem":"85"},{"json":"84","pairedItem":"86"},{"headers":"87","params":"88","query":"89","body":"90","webhookUrl":"91","executionMode":"92"},{"item":0},{"valid":true,"userId":1},{"item":0},{"item":0},{"used_tokens":"93","quota_tokens":"94","tokens_remaining":"95"},{"item":0},{"success":true,"used_tokens":14353,"quota_tokens":50000,"tokens_remaining":35647},{"item":0},{"item":0},{"host":"96","x-real-ip":"97","x-forwarded-for":"97","x-forwarded-proto":"98","connection":"99","sec-ch-ua-platform":"100","authorization":"101","user-agent":"102","accept":"103","sec-ch-ua":"104","dnt":"105","sec-ch-ua-mobile":"106","sec-fetch-site":"107","sec-fetch-mode":"108","sec-fetch-dest":"109","referer":"110","accept-encoding":"111","accept-language":"112","cookie":"113","sec-gpc":"105","if-none-match":"114"},{},{},{},"http://localhost:5678/webhook/wibot/user/tokens","production","14353","50000","35647","localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzIyMTYsImV4cCI6MTc2Njg1ODYxNn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","W/\\"52-eHX1zguHDxHiVPOLsHSEAK1e2d4\\""]
117	{"id":"yPYTzGXVRP2JQxs8","name":"WIBOT - Get Conversations","active":true,"activeVersionId":"e1bae720-4a31-4afe-a595-4a35f7e26b0f","isArchived":false,"createdAt":"2025-12-26T17:23:46.197Z","updatedAt":"2025-12-26T17:24:07.735Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/conversations","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"c0f9fbaf-d0bb-4e86-92e9-c3e34e750679","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-656,112],"webhookId":"wibot-conversations"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"a5bd8ac1-82cc-4021-8420-752f46440f49","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"352ea961-e9a7-4651-acad-b594ba9f1c8c","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"9a0fd5d7-2e41-4111-b2b2-f84c1403ea28","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  c.conversation_id::text,\\n  c.title,\\n  TO_CHAR(c.updated_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as updated_at,\\n  COUNT(m.message_id)::integer as message_count\\nFROM conversations c\\nLEFT JOIN messages m ON c.conversation_id = m.conversation_id\\nWHERE c.user_id = {{ $json.userId }}\\nGROUP BY c.conversation_id, c.title, c.updated_at\\nORDER BY c.updated_at DESC\\nLIMIT 50;","options":{}},"id":"8fe150d4-0f4e-41ac-bd90-8978f31f4459","name":"Get Conversations","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[0,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats ou resultats vides\\nif (!rows || rows.length === 0 || !rows[0].json.conversation_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      conversations: []\\n    }\\n  }];\\n}\\n\\nconst conversations = rows.map(row => ({\\n  conversation_id: row.json.conversation_id,\\n  title: row.json.title || 'Nouvelle conversation',\\n  updated_at: row.json.updated_at,\\n  message_count: parseInt(row.json.message_count) || 0\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    conversations\\n  }\\n}];","notice":""},"id":"8d9137c5-9aa8-4938-961f-50bdbc93ee8f","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"463fcf83-1d8e-472a-94df-623b505f1a5d","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[448,0]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Conversations","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Conversations":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Conversations":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766786348272,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766786348272,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766786348272,"executionIndex":1,"source":"29","hints":"30","executionTime":4,"executionStatus":"27","data":"31"},{"startTime":1766786348276,"executionIndex":2,"source":"32","hints":"33","executionTime":1,"executionStatus":"27","data":"34"},{"startTime":1766786348277,"executionIndex":3,"source":"35","hints":"36","executionTime":24,"executionStatus":"27","data":"37"},{"startTime":1766786348301,"executionIndex":4,"source":"38","hints":"39","executionTime":3,"executionStatus":"27","data":"40"},{"startTime":1766786348304,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75","76","77"],"Get Conversations",["78"],"Format Response",["79"],{"json":"80","pairedItem":"81"},{"json":"82","pairedItem":"83"},{"json":"82","pairedItem":"84"},{"json":"85","pairedItem":"86"},{"json":"87","pairedItem":"86"},{"json":"88","pairedItem":"86"},{"json":"89","pairedItem":"86"},{"json":"90"},{"json":"90","pairedItem":"91"},{"headers":"92","params":"93","query":"94","body":"95","webhookUrl":"96","executionMode":"97"},{"item":0},{"valid":true,"userId":1},{"item":0},{"item":0},{"conversation_id":"98","title":"99","updated_at":"100","message_count":2},{"item":0},{"conversation_id":"101","title":"102","updated_at":"103","message_count":8},{"conversation_id":"104","title":"105","updated_at":"106","message_count":12},{"conversation_id":"107","title":"108","updated_at":"109","message_count":14},{"success":true,"conversations":"110"},{"item":0},{"host":"111","x-real-ip":"112","x-forwarded-for":"112","x-forwarded-proto":"113","connection":"114","sec-ch-ua-platform":"115","authorization":"116","user-agent":"117","accept":"118","sec-ch-ua":"119","dnt":"120","sec-ch-ua-mobile":"121","sec-fetch-site":"122","sec-fetch-mode":"123","sec-fetch-dest":"124","referer":"125","accept-encoding":"126","accept-language":"127","cookie":"128","sec-gpc":"120","if-none-match":"129"},{},{},{},"http://localhost:5678/webhook/wibot/conversations","production","419ba4c9-f14d-4af2-83b3-ba2399c17ffb","tu es tristes ?","2025-12-26T18:02:55Z","963eb9f1-fdcc-4cd5-918b-29fae40c17a0","quel est le chiffre important que je t'ai donné ?","2025-12-26T17:34:13Z","550e8400-e29b-41d4-a716-446655440000","Conversation de test","2025-12-26T17:28:13Z","3cc2c8db-afef-4637-accc-31d259f53857","saluty","2025-12-26T16:45:24Z",["130","131","132","133"],"localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzIyMTYsImV4cCI6MTc2Njg1ODYxNn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","W/\\"26f-vT5fVP674oqMWVPWp39kPkaUWpU\\"",{"conversation_id":"98","title":"99","updated_at":"100","message_count":2},{"conversation_id":"101","title":"102","updated_at":"103","message_count":8},{"conversation_id":"104","title":"105","updated_at":"106","message_count":12},{"conversation_id":"107","title":"108","updated_at":"109","message_count":14}]
119	{"id":"c8fbjjX9ObuzBE4b","name":"WIBOT - Get User Tokens","active":true,"activeVersionId":"62643582-5e10-4f85-9c6c-74a85d102e67","isArchived":false,"createdAt":"2025-12-26T17:24:01.471Z","updatedAt":"2025-12-26T17:24:05.529Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/user/tokens","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"8fcee23f-b3e4-4c28-ad04-4ba456f7752a","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-656,112],"webhookId":"wibot-user-tokens"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"d8de2cd5-94e4-49a5-a318-1ee1c389abd9","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"c9c309e4-53ba-46be-8960-13da82f4f5f7","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"83cd3ac8-fb46-4de5-a8ce-5d24be08334c","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  COALESCE(used_tokens, 0) as used_tokens,\\n  COALESCE(quota_tokens, 50000) as quota_tokens,\\n  COALESCE(quota_tokens, 50000) - COALESCE(used_tokens, 0) as tokens_remaining\\nFROM user_token_usage\\nWHERE user_id = {{ $json.userId }}\\n  AND month = DATE_TRUNC('month', CURRENT_DATE)\\nLIMIT 1;","options":{}},"id":"b35fa964-24c4-49ed-a3b6-7df917662ceb","name":"Get Token Usage","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[0,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\nconst jwtData = $('Verify JWT').first().json;\\n\\n// Si pas de donnees, l'utilisateur n'a pas encore utilise de tokens ce mois\\nif (!rows || rows.length === 0 || rows[0].json.tokens_remaining === undefined) {\\n  return [{\\n    json: {\\n      success: true,\\n      used_tokens: 0,\\n      quota_tokens: 50000,\\n      tokens_remaining: 50000\\n    }\\n  }];\\n}\\n\\nconst data = rows[0].json;\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    used_tokens: parseInt(data.used_tokens) || 0,\\n    quota_tokens: parseInt(data.quota_tokens) || 50000,\\n    tokens_remaining: parseInt(data.tokens_remaining) || 50000\\n  }\\n}];","notice":""},"id":"7d9b1764-6fed-49d3-957f-402aa7f05696","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"67daad4e-a2fe-4b36-b18c-065181b80de3","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[448,0]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Token Usage","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Token Usage":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Token Usage":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766786348351,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766786348351,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766786348351,"executionIndex":1,"source":"29","hints":"30","executionTime":3,"executionStatus":"27","data":"31"},{"startTime":1766786348354,"executionIndex":2,"source":"32","hints":"33","executionTime":1,"executionStatus":"27","data":"34"},{"startTime":1766786348355,"executionIndex":3,"source":"35","hints":"36","executionTime":14,"executionStatus":"27","data":"37"},{"startTime":1766786348369,"executionIndex":4,"source":"38","hints":"39","executionTime":4,"executionStatus":"27","data":"40"},{"startTime":1766786348373,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74"],"Get Token Usage",["75"],"Format Response",["76"],{"json":"77","pairedItem":"78"},{"json":"79","pairedItem":"80"},{"json":"79","pairedItem":"81"},{"json":"82","pairedItem":"83"},{"json":"84","pairedItem":"85"},{"json":"84","pairedItem":"86"},{"headers":"87","params":"88","query":"89","body":"90","webhookUrl":"91","executionMode":"92"},{"item":0},{"valid":true,"userId":1},{"item":0},{"item":0},{"used_tokens":"93","quota_tokens":"94","tokens_remaining":"95"},{"item":0},{"success":true,"used_tokens":14353,"quota_tokens":50000,"tokens_remaining":35647},{"item":0},{"item":0},{"host":"96","x-real-ip":"97","x-forwarded-for":"97","x-forwarded-proto":"98","connection":"99","sec-ch-ua-platform":"100","authorization":"101","user-agent":"102","accept":"103","sec-ch-ua":"104","dnt":"105","sec-ch-ua-mobile":"106","sec-fetch-site":"107","sec-fetch-mode":"108","sec-fetch-dest":"109","referer":"110","accept-encoding":"111","accept-language":"112","cookie":"113","sec-gpc":"105","if-none-match":"114"},{},{},{},"http://localhost:5678/webhook/wibot/user/tokens","production","14353","50000","35647","localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzIyMTYsImV4cCI6MTc2Njg1ODYxNn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","W/\\"52-eHX1zguHDxHiVPOLsHSEAK1e2d4\\""]
120	{"id":"yPYTzGXVRP2JQxs8","name":"WIBOT - Get Conversations","active":true,"activeVersionId":"e1bae720-4a31-4afe-a595-4a35f7e26b0f","isArchived":false,"createdAt":"2025-12-26T17:23:46.197Z","updatedAt":"2025-12-26T17:24:07.735Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/conversations","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"c0f9fbaf-d0bb-4e86-92e9-c3e34e750679","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-656,112],"webhookId":"wibot-conversations"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"a5bd8ac1-82cc-4021-8420-752f46440f49","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"352ea961-e9a7-4651-acad-b594ba9f1c8c","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"9a0fd5d7-2e41-4111-b2b2-f84c1403ea28","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  c.conversation_id::text,\\n  c.title,\\n  TO_CHAR(c.updated_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as updated_at,\\n  COUNT(m.message_id)::integer as message_count\\nFROM conversations c\\nLEFT JOIN messages m ON c.conversation_id = m.conversation_id\\nWHERE c.user_id = {{ $json.userId }}\\nGROUP BY c.conversation_id, c.title, c.updated_at\\nORDER BY c.updated_at DESC\\nLIMIT 50;","options":{}},"id":"8fe150d4-0f4e-41ac-bd90-8978f31f4459","name":"Get Conversations","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[0,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats ou resultats vides\\nif (!rows || rows.length === 0 || !rows[0].json.conversation_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      conversations: []\\n    }\\n  }];\\n}\\n\\nconst conversations = rows.map(row => ({\\n  conversation_id: row.json.conversation_id,\\n  title: row.json.title || 'Nouvelle conversation',\\n  updated_at: row.json.updated_at,\\n  message_count: parseInt(row.json.message_count) || 0\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    conversations\\n  }\\n}];","notice":""},"id":"8d9137c5-9aa8-4938-961f-50bdbc93ee8f","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"463fcf83-1d8e-472a-94df-623b505f1a5d","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[448,0]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Conversations","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Conversations":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Conversations":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766786348363,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766786348363,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766786348363,"executionIndex":1,"source":"29","hints":"30","executionTime":2,"executionStatus":"27","data":"31"},{"startTime":1766786348365,"executionIndex":2,"source":"32","hints":"33","executionTime":1,"executionStatus":"27","data":"34"},{"startTime":1766786348366,"executionIndex":3,"source":"35","hints":"36","executionTime":15,"executionStatus":"27","data":"37"},{"startTime":1766786348381,"executionIndex":4,"source":"38","hints":"39","executionTime":2,"executionStatus":"27","data":"40"},{"startTime":1766786348383,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75","76","77"],"Get Conversations",["78"],"Format Response",["79"],{"json":"80","pairedItem":"81"},{"json":"82","pairedItem":"83"},{"json":"82","pairedItem":"84"},{"json":"85","pairedItem":"86"},{"json":"87","pairedItem":"86"},{"json":"88","pairedItem":"86"},{"json":"89","pairedItem":"86"},{"json":"90"},{"json":"90","pairedItem":"91"},{"headers":"92","params":"93","query":"94","body":"95","webhookUrl":"96","executionMode":"97"},{"item":0},{"valid":true,"userId":1},{"item":0},{"item":0},{"conversation_id":"98","title":"99","updated_at":"100","message_count":2},{"item":0},{"conversation_id":"101","title":"102","updated_at":"103","message_count":8},{"conversation_id":"104","title":"105","updated_at":"106","message_count":12},{"conversation_id":"107","title":"108","updated_at":"109","message_count":14},{"success":true,"conversations":"110"},{"item":0},{"host":"111","x-real-ip":"112","x-forwarded-for":"112","x-forwarded-proto":"113","connection":"114","sec-ch-ua-platform":"115","authorization":"116","user-agent":"117","accept":"118","sec-ch-ua":"119","dnt":"120","sec-ch-ua-mobile":"121","sec-fetch-site":"122","sec-fetch-mode":"123","sec-fetch-dest":"124","referer":"125","accept-encoding":"126","accept-language":"127","cookie":"128","sec-gpc":"120","if-none-match":"129"},{},{},{},"http://localhost:5678/webhook/wibot/conversations","production","419ba4c9-f14d-4af2-83b3-ba2399c17ffb","tu es tristes ?","2025-12-26T18:02:55Z","963eb9f1-fdcc-4cd5-918b-29fae40c17a0","quel est le chiffre important que je t'ai donné ?","2025-12-26T17:34:13Z","550e8400-e29b-41d4-a716-446655440000","Conversation de test","2025-12-26T17:28:13Z","3cc2c8db-afef-4637-accc-31d259f53857","saluty","2025-12-26T16:45:24Z",["130","131","132","133"],"localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzIyMTYsImV4cCI6MTc2Njg1ODYxNn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","W/\\"26f-vT5fVP674oqMWVPWp39kPkaUWpU\\"",{"conversation_id":"98","title":"99","updated_at":"100","message_count":2},{"conversation_id":"101","title":"102","updated_at":"103","message_count":8},{"conversation_id":"104","title":"105","updated_at":"106","message_count":12},{"conversation_id":"107","title":"108","updated_at":"109","message_count":14}]
121	{"id":"msg5c740bd9db51","name":"WIBOT - Get Messages","active":true,"activeVersionId":"704bc444-e5e2-4901-9322-383bc1bd0434","isArchived":false,"createdAt":"2025-12-26T17:58:10.218Z","updatedAt":"2025-12-26T17:58:10.218Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/messages","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"webhook-messages","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,300],"webhookId":"wibot-messages"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst conversationId = $input.first().json.query.conversationId;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nif (!conversationId) {\\n  return [{ json: { valid: false, error: 'conversationId is required' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId, conversationId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"verify-jwt","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[470,300]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"if-jwt-valid","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[690,300]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-unauthorized","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[910,450]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  m.message_id,\\n  m.role,\\n  m.content,\\n  TO_CHAR(m.created_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as created_at\\nFROM messages m\\nJOIN conversations c ON m.conversation_id = c.conversation_id\\nWHERE m.conversation_id = '{{ $json.conversationId }}'::uuid\\n  AND c.user_id = {{ $json.userId }}\\nORDER BY m.created_at ASC;","options":{}},"id":"get-messages","name":"Get Messages","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[910,200],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats, retourner liste vide\\nif (!rows || rows.length === 0 || !rows[0].json.message_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      messages: []\\n    }\\n  }];\\n}\\n\\nconst messages = rows.map(row => ({\\n  message_id: row.json.message_id,\\n  role: row.json.role,\\n  content: row.json.content,\\n  created_at: row.json.created_at\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    messages\\n  }\\n}];","notice":""},"id":"format-response","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1130,200]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-success","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1350,200]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Messages","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Messages":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Messages":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766786348376,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766786348376,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766786348376,"executionIndex":1,"source":"29","hints":"30","executionTime":3,"executionStatus":"27","data":"31"},{"startTime":1766786348380,"executionIndex":2,"source":"32","hints":"33","executionTime":0,"executionStatus":"27","data":"34"},{"startTime":1766786348380,"executionIndex":3,"source":"35","hints":"36","executionTime":8,"executionStatus":"27","data":"37"},{"startTime":1766786348388,"executionIndex":4,"source":"38","hints":"39","executionTime":3,"executionStatus":"27","data":"40"},{"startTime":1766786348391,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75"],"Get Messages",["76"],"Format Response",["77"],{"json":"78","pairedItem":"79"},{"json":"80","pairedItem":"81"},{"json":"80","pairedItem":"82"},{"json":"83","pairedItem":"84"},{"json":"85","pairedItem":"84"},{"json":"86"},{"json":"86","pairedItem":"87"},{"headers":"88","params":"89","query":"90","body":"91","webhookUrl":"92","executionMode":"93"},{"item":0},{"valid":true,"userId":1,"conversationId":"94"},{"item":0},{"item":0},{"message_id":35,"role":"95","content":"96","created_at":"97"},{"item":0},{"message_id":36,"role":"98","content":"99","created_at":"97"},{"success":true,"messages":"100"},{"item":0},{"host":"101","x-real-ip":"102","x-forwarded-for":"102","x-forwarded-proto":"103","connection":"104","sec-ch-ua-platform":"105","authorization":"106","user-agent":"107","accept":"108","sec-ch-ua":"109","dnt":"110","sec-ch-ua-mobile":"111","sec-fetch-site":"112","sec-fetch-mode":"113","sec-fetch-dest":"114","referer":"115","accept-encoding":"116","accept-language":"117","cookie":"118","sec-gpc":"110","if-none-match":"119"},{},{"conversationId":"94"},{},"http://localhost:5678/webhook/wibot/messages","production","419ba4c9-f14d-4af2-83b3-ba2399c17ffb","user","tu es tristes ?","2025-12-26T18:02:55Z","assistant","Non, je ne suis pas triste. En tant qu'IA, je n'ai pas de sentiments ou d'émotions. Mon rôle est de vous aider avec vos questions techniques et de fournir des réponses claires et professionnelles. Comment puis-je vous aider aujourd'hui ?",["120","121"],"localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzIyMTYsImV4cCI6MTc2Njg1ODYxNn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","W/\\"1c3-FLRNx9lSWv1AwsfyAn02Yeb78cA\\"",{"message_id":35,"role":"95","content":"96","created_at":"97"},{"message_id":36,"role":"98","content":"99","created_at":"97"}]
122	{"id":"msg5c740bd9db51","name":"WIBOT - Get Messages","active":true,"activeVersionId":"704bc444-e5e2-4901-9322-383bc1bd0434","isArchived":false,"createdAt":"2025-12-26T17:58:10.218Z","updatedAt":"2025-12-26T17:58:10.218Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/messages","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"webhook-messages","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,300],"webhookId":"wibot-messages"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst conversationId = $input.first().json.query.conversationId;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nif (!conversationId) {\\n  return [{ json: { valid: false, error: 'conversationId is required' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId, conversationId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"verify-jwt","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[470,300]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"if-jwt-valid","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[690,300]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-unauthorized","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[910,450]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  m.message_id,\\n  m.role,\\n  m.content,\\n  TO_CHAR(m.created_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as created_at\\nFROM messages m\\nJOIN conversations c ON m.conversation_id = c.conversation_id\\nWHERE m.conversation_id = '{{ $json.conversationId }}'::uuid\\n  AND c.user_id = {{ $json.userId }}\\nORDER BY m.created_at ASC;","options":{}},"id":"get-messages","name":"Get Messages","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[910,200],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats, retourner liste vide\\nif (!rows || rows.length === 0 || !rows[0].json.message_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      messages: []\\n    }\\n  }];\\n}\\n\\nconst messages = rows.map(row => ({\\n  message_id: row.json.message_id,\\n  role: row.json.role,\\n  content: row.json.content,\\n  created_at: row.json.created_at\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    messages\\n  }\\n}];","notice":""},"id":"format-response","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1130,200]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-success","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1350,200]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Messages","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Messages":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Messages":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766786348413,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766786348413,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766786348413,"executionIndex":1,"source":"29","hints":"30","executionTime":3,"executionStatus":"27","data":"31"},{"startTime":1766786348416,"executionIndex":2,"source":"32","hints":"33","executionTime":1,"executionStatus":"27","data":"34"},{"startTime":1766786348417,"executionIndex":3,"source":"35","hints":"36","executionTime":3,"executionStatus":"27","data":"37"},{"startTime":1766786348420,"executionIndex":4,"source":"38","hints":"39","executionTime":2,"executionStatus":"27","data":"40"},{"startTime":1766786348422,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75"],"Get Messages",["76"],"Format Response",["77"],{"json":"78","pairedItem":"79"},{"json":"80","pairedItem":"81"},{"json":"80","pairedItem":"82"},{"json":"83","pairedItem":"84"},{"json":"85","pairedItem":"84"},{"json":"86"},{"json":"86","pairedItem":"87"},{"headers":"88","params":"89","query":"90","body":"91","webhookUrl":"92","executionMode":"93"},{"item":0},{"valid":true,"userId":1,"conversationId":"94"},{"item":0},{"item":0},{"message_id":35,"role":"95","content":"96","created_at":"97"},{"item":0},{"message_id":36,"role":"98","content":"99","created_at":"97"},{"success":true,"messages":"100"},{"item":0},{"host":"101","x-real-ip":"102","x-forwarded-for":"102","x-forwarded-proto":"103","connection":"104","sec-ch-ua-platform":"105","authorization":"106","user-agent":"107","accept":"108","sec-ch-ua":"109","dnt":"110","sec-ch-ua-mobile":"111","sec-fetch-site":"112","sec-fetch-mode":"113","sec-fetch-dest":"114","referer":"115","accept-encoding":"116","accept-language":"117","cookie":"118","sec-gpc":"110","if-none-match":"119"},{},{"conversationId":"94"},{},"http://localhost:5678/webhook/wibot/messages","production","419ba4c9-f14d-4af2-83b3-ba2399c17ffb","user","tu es tristes ?","2025-12-26T18:02:55Z","assistant","Non, je ne suis pas triste. En tant qu'IA, je n'ai pas de sentiments ou d'émotions. Mon rôle est de vous aider avec vos questions techniques et de fournir des réponses claires et professionnelles. Comment puis-je vous aider aujourd'hui ?",["120","121"],"localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzIyMTYsImV4cCI6MTc2Njg1ODYxNn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","W/\\"1c3-FLRNx9lSWv1AwsfyAn02Yeb78cA\\"",{"message_id":35,"role":"95","content":"96","created_at":"97"},{"message_id":36,"role":"98","content":"99","created_at":"97"}]
123	{"id":"msg5c740bd9db51","name":"WIBOT - Get Messages","active":true,"activeVersionId":"704bc444-e5e2-4901-9322-383bc1bd0434","isArchived":false,"createdAt":"2025-12-26T17:58:10.218Z","updatedAt":"2025-12-26T17:58:10.218Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/messages","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"webhook-messages","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,300],"webhookId":"wibot-messages"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst conversationId = $input.first().json.query.conversationId;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nif (!conversationId) {\\n  return [{ json: { valid: false, error: 'conversationId is required' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId, conversationId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"verify-jwt","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[470,300]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"if-jwt-valid","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[690,300]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-unauthorized","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[910,450]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  m.message_id,\\n  m.role,\\n  m.content,\\n  TO_CHAR(m.created_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as created_at\\nFROM messages m\\nJOIN conversations c ON m.conversation_id = c.conversation_id\\nWHERE m.conversation_id = '{{ $json.conversationId }}'::uuid\\n  AND c.user_id = {{ $json.userId }}\\nORDER BY m.created_at ASC;","options":{}},"id":"get-messages","name":"Get Messages","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[910,200],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats, retourner liste vide\\nif (!rows || rows.length === 0 || !rows[0].json.message_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      messages: []\\n    }\\n  }];\\n}\\n\\nconst messages = rows.map(row => ({\\n  message_id: row.json.message_id,\\n  role: row.json.role,\\n  content: row.json.content,\\n  created_at: row.json.created_at\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    messages\\n  }\\n}];","notice":""},"id":"format-response","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1130,200]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-success","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1350,200]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Messages","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Messages":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Messages":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766786351082,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766786351082,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766786351083,"executionIndex":1,"source":"29","hints":"30","executionTime":2,"executionStatus":"27","data":"31"},{"startTime":1766786351085,"executionIndex":2,"source":"32","hints":"33","executionTime":1,"executionStatus":"27","data":"34"},{"startTime":1766786351086,"executionIndex":3,"source":"35","hints":"36","executionTime":2,"executionStatus":"27","data":"37"},{"startTime":1766786351088,"executionIndex":4,"source":"38","hints":"39","executionTime":2,"executionStatus":"27","data":"40"},{"startTime":1766786351090,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75","76","77","78","79","80","81"],"Get Messages",["82"],"Format Response",["83"],{"json":"84","pairedItem":"85"},{"json":"86","pairedItem":"87"},{"json":"86","pairedItem":"88"},{"json":"89","pairedItem":"90"},{"json":"91","pairedItem":"90"},{"json":"92","pairedItem":"90"},{"json":"93","pairedItem":"90"},{"json":"94","pairedItem":"90"},{"json":"95","pairedItem":"90"},{"json":"96","pairedItem":"90"},{"json":"97","pairedItem":"90"},{"json":"98"},{"json":"98","pairedItem":"99"},{"headers":"100","params":"101","query":"102","body":"103","webhookUrl":"104","executionMode":"105"},{"item":0},{"valid":true,"userId":1,"conversationId":"106"},{"item":0},{"item":0},{"message_id":21,"role":"107","content":"108","created_at":"109"},{"item":0},{"message_id":22,"role":"110","content":"111","created_at":"109"},{"message_id":23,"role":"107","content":"112","created_at":"113"},{"message_id":24,"role":"110","content":"114","created_at":"113"},{"message_id":25,"role":"107","content":"112","created_at":"115"},{"message_id":26,"role":"110","content":"116","created_at":"115"},{"message_id":33,"role":"107","content":"117","created_at":"118"},{"message_id":34,"role":"110","content":"119","created_at":"118"},{"success":true,"messages":"120"},{"item":0},{"host":"121","x-real-ip":"122","x-forwarded-for":"122","x-forwarded-proto":"123","connection":"124","sec-ch-ua-platform":"125","authorization":"126","user-agent":"127","accept":"128","sec-ch-ua":"129","dnt":"130","sec-ch-ua-mobile":"131","sec-fetch-site":"132","sec-fetch-mode":"133","sec-fetch-dest":"134","referer":"135","accept-encoding":"136","accept-language":"137","cookie":"138","sec-gpc":"130","if-none-match":"139"},{},{"conversationId":"106"},{},"http://localhost:5678/webhook/wibot/messages","production","963eb9f1-fdcc-4cd5-918b-29fae40c17a0","user","quel est le chiffre important que je t'ai donné ?","2025-12-26T16:45:37Z","assistant","Je n'ai pas de mémoire persistante entre nos interactions, donc je ne peux pas me souvenir des informations partagées lors de nos précédentes conversations. Si vous me donnez à nouveau le chiffre important, je serai ravi de vous aider avec celui-ci.\\n\\nN'hésitez pas à me le communiquer !","salut","2025-12-26T17:13:49Z","Salut ! Comment puis-je vous aider aujourd'hui ? 😊","2025-12-26T17:14:33Z","Bonjour ! Comment puis-je vous aider aujourd'hui ? 😊","dsf ça va ?","2025-12-26T17:34:13Z","Bonjour ! Je vais très bien, merci de demander. 😊\\n\\nComment puis-je vous aider aujourd'hui ?",["140","141","142","143","144","145","146","147"],"localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzIyMTYsImV4cCI6MTc2Njg1ODYxNn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","W/\\"4f5-iX7OrMLhqWRZ+Pgvd44GsjyMq3A\\"",{"message_id":21,"role":"107","content":"108","created_at":"109"},{"message_id":22,"role":"110","content":"111","created_at":"109"},{"message_id":23,"role":"107","content":"112","created_at":"113"},{"message_id":24,"role":"110","content":"114","created_at":"113"},{"message_id":25,"role":"107","content":"112","created_at":"115"},{"message_id":26,"role":"110","content":"116","created_at":"115"},{"message_id":33,"role":"107","content":"117","created_at":"118"},{"message_id":34,"role":"110","content":"119","created_at":"118"}]
125	{"id":"msg5c740bd9db51","name":"WIBOT - Get Messages","active":true,"activeVersionId":"704bc444-e5e2-4901-9322-383bc1bd0434","isArchived":false,"createdAt":"2025-12-26T17:58:10.218Z","updatedAt":"2025-12-26T17:58:10.218Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/messages","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"webhook-messages","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,300],"webhookId":"wibot-messages"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst conversationId = $input.first().json.query.conversationId;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nif (!conversationId) {\\n  return [{ json: { valid: false, error: 'conversationId is required' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId, conversationId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"verify-jwt","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[470,300]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"if-jwt-valid","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[690,300]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-unauthorized","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[910,450]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  m.message_id,\\n  m.role,\\n  m.content,\\n  TO_CHAR(m.created_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as created_at\\nFROM messages m\\nJOIN conversations c ON m.conversation_id = c.conversation_id\\nWHERE m.conversation_id = '{{ $json.conversationId }}'::uuid\\n  AND c.user_id = {{ $json.userId }}\\nORDER BY m.created_at ASC;","options":{}},"id":"get-messages","name":"Get Messages","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[910,200],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats, retourner liste vide\\nif (!rows || rows.length === 0 || !rows[0].json.message_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      messages: []\\n    }\\n  }];\\n}\\n\\nconst messages = rows.map(row => ({\\n  message_id: row.json.message_id,\\n  role: row.json.role,\\n  content: row.json.content,\\n  created_at: row.json.created_at\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    messages\\n  }\\n}];","notice":""},"id":"format-response","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1130,200]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-success","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1350,200]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Messages","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Messages":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Messages":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766786352875,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766786352875,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766786352875,"executionIndex":1,"source":"29","hints":"30","executionTime":3,"executionStatus":"27","data":"31"},{"startTime":1766786352878,"executionIndex":2,"source":"32","hints":"33","executionTime":1,"executionStatus":"27","data":"34"},{"startTime":1766786352879,"executionIndex":3,"source":"35","hints":"36","executionTime":2,"executionStatus":"27","data":"37"},{"startTime":1766786352881,"executionIndex":4,"source":"38","hints":"39","executionTime":2,"executionStatus":"27","data":"40"},{"startTime":1766786352883,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75","76","77","78","79","80","81","82","83","84","85","86","87"],"Get Messages",["88"],"Format Response",["89"],{"json":"90","pairedItem":"91"},{"json":"92","pairedItem":"93"},{"json":"92","pairedItem":"94"},{"json":"95","pairedItem":"96"},{"json":"97","pairedItem":"96"},{"json":"98","pairedItem":"96"},{"json":"99","pairedItem":"96"},{"json":"100","pairedItem":"96"},{"json":"101","pairedItem":"96"},{"json":"102","pairedItem":"96"},{"json":"103","pairedItem":"96"},{"json":"104","pairedItem":"96"},{"json":"105","pairedItem":"96"},{"json":"106","pairedItem":"96"},{"json":"107","pairedItem":"96"},{"json":"108","pairedItem":"96"},{"json":"109","pairedItem":"96"},{"json":"110"},{"json":"110","pairedItem":"111"},{"headers":"112","params":"113","query":"114","body":"115","webhookUrl":"116","executionMode":"117"},{"item":0},{"valid":true,"userId":1,"conversationId":"118"},{"item":0},{"item":0},{"message_id":7,"role":"119","content":"120","created_at":"121"},{"item":0},{"message_id":8,"role":"122","content":"123","created_at":"121"},{"message_id":9,"role":"119","content":"124","created_at":"125"},{"message_id":10,"role":"122","content":"126","created_at":"125"},{"message_id":11,"role":"119","content":"127","created_at":"128"},{"message_id":12,"role":"122","content":"129","created_at":"128"},{"message_id":13,"role":"119","content":"130","created_at":"131"},{"message_id":14,"role":"122","content":"132","created_at":"131"},{"message_id":15,"role":"119","content":"133","created_at":"134"},{"message_id":16,"role":"122","content":"135","created_at":"134"},{"message_id":17,"role":"119","content":"136","created_at":"137"},{"message_id":18,"role":"122","content":"138","created_at":"137"},{"message_id":19,"role":"119","content":"139","created_at":"140"},{"message_id":20,"role":"122","content":"141","created_at":"140"},{"success":true,"messages":"142"},{"item":0},{"host":"143","x-real-ip":"144","x-forwarded-for":"144","x-forwarded-proto":"145","connection":"146","sec-ch-ua-platform":"147","authorization":"148","user-agent":"149","accept":"150","sec-ch-ua":"151","dnt":"152","sec-ch-ua-mobile":"153","sec-fetch-site":"154","sec-fetch-mode":"155","sec-fetch-dest":"156","referer":"157","accept-encoding":"158","accept-language":"159","cookie":"160","sec-gpc":"152","if-none-match":"161"},{},{"conversationId":"118"},{},"http://localhost:5678/webhook/wibot/messages","production","3cc2c8db-afef-4637-accc-31d259f53857","user","saluty","2025-12-26T16:43:14Z","assistant","Bonjour ! Comment puis-je vous aider aujourd'hui ?","tout va bien ?","2025-12-26T16:43:24Z","Tout va très bien, merci de demander ! Je suis prêt à vous aider avec vos questions techniques. Comment puis-je vous assister aujourd'hui ?","genere un max de text je test la conso token","2025-12-26T16:43:40Z","Je comprends que vous souhaitez tester la consommation de tokens. Voici un texte plus long pour vous aider dans votre test :\\n\\n---\\n\\nChez WIDIP, nous sommes une entreprise française de services informatiques spécialisée dans l'accompagnement des entreprises dans leur transformation numérique. Notre mission est de fournir des solutions technologiques innovantes et sur mesure pour répondre aux besoins spécifiques de nos clients.\\n\\nNous offrons une large gamme de services, allant du développement de logiciels sur mesure à l'infogérance, en passant par la cybersécurité et le cloud computing. Notre équipe d'experts est composée de professionnels qualifiés et passionnés, toujours prêts à relever les défis technologiques les plus complexes.\\n\\nChez WIDIP, nous croyons en l'importance de la collaboration et de la communication. Nous travaillons en étroite collaboration avec nos clients pour comprendre leurs besoins et leurs attentes, et nous nous engageons à fournir des solutions qui non seulement répondent à ces besoins, mais qui les dépassent.\\n\\nNous sommes également convaincus que la formation et le développement des compétences sont essentiels pour rester à la pointe de la technologie. C'est pourquoi nous investissons continuellement dans la formation de nos employés et dans l'acquisition de nouvelles compétences.\\n\\nEn choisissant WIDIP, vous bénéficiez de notre expertise, de notre engagement et de notre passion pour la technologie. Nous sommes là pour vous accompagner à chaque étape de votre transformation numérique, en vous fournissant des solutions qui vous permettent de tirer le meilleur parti de la technologie.\\n\\nSi vous avez des questions ou si vous souhaitez en savoir plus sur nos services, n'hésitez pas à nous contacter. Nous serons ravis de vous aider.\\n\\n---\\n\\nJ'espère que ce texte répond à vos besoins pour le test de consommation de tokens. Si vous avez d'autres questions ou besoin de plus d'informations, n'hésitez pas à me le faire savoir !","encore","2025-12-26T16:43:51Z","Bien sûr ! Voici un texte encore plus long pour votre test de consommation de tokens :\\n\\n---\\n\\nChez WIDIP, nous sommes une entreprise française de services informatiques spécialisée dans l'accompagnement des entreprises dans leur transformation numérique. Notre mission est de fournir des solutions technologiques innovantes et sur mesure pour répondre aux besoins spécifiques de nos clients.\\n\\nNous offrons une large gamme de services, allant du développement de logiciels sur mesure à l'infogérance, en passant par la cybersécurité et le cloud computing. Notre équipe d'experts est composée de professionnels qualifiés et passionnés, toujours prêts à relever les défis technologiques les plus complexes.\\n\\nChez WIDIP, nous croyons en l'importance de la collaboration et de la communication. Nous travaillons en étroite collaboration avec nos clients pour comprendre leurs besoins et leurs attentes, et nous nous engageons à fournir des solutions qui non seulement répondent à ces besoins, mais qui les dépassent.\\n\\nNous sommes également convaincus que la formation et le développement des compétences sont essentiels pour rester à la pointe de la technologie. C'est pourquoi nous investissons continuellement dans la formation de nos employés et dans l'acquisition de nouvelles compétences.\\n\\nEn choisissant WIDIP, vous bénéficiez de notre expertise, de notre engagement et de notre passion pour la technologie. Nous sommes là pour vous accompagner à chaque étape de votre transformation numérique, en vous fournissant des solutions qui vous permettent de tirer le meilleur parti de la technologie.\\n\\nSi vous avez des questions ou si vous souhaitez en savoir plus sur nos services, n'hésitez pas à nous contacter. Nous serons ravis de vous aider.\\n\\n---\\n\\nVoici un exemple de code en Python pour illustrer nos compétences en développement de logiciels :\\n\\n```python\\n# Exemple de code Python pour calculer la factorielle d'un nombre\\n\\ndef factorielle(n):\\n    if n == 0:\\n        return 1\\n    else:\\n        return n * factorielle(n - 1)\\n\\n# Exemple d'utilisation\\nnombre = 5\\nresultat = factorielle(nombre)\\nprint(f\\"La factorielle de {nombre} est {resultat}\\")\\n```\\n\\nChez WIDIP, nous utilisons des technologies de pointe pour développer des solutions robustes et évolutives. Nos développeurs sont expérimentés dans divers langages de programmation, tels que Python, Java, C++, et bien d'autres.\\n\\nNous mettons également un point d'honneur à suivre les meilleures pratiques en matière de développement logiciel, telles que la programmation orientée objet, les tests unitaires, et la documentation du code. Nous croyons que ces pratiques sont essentielles pour garantir la qualité et la maintenabilité de nos solutions.\\n\\nEn plus du développement de logiciels, nous offrons également des services d'infogérance pour aider nos clients à gérer leurs infrastructures informatiques. Nos experts en infogérance peuvent vous aider à optimiser vos systèmes, à améliorer leur sécurité, et à assurer leur disponibilité.\\n\\nNous proposons également des services de cybersécurité pour protéger vos données et vos systèmes contre les cybermenaces. Nos experts en cybersécurité peuvent vous aider à mettre en place des mesures de sécurité efficaces, à effectuer des audits de sécurité, et à répondre aux incidents de sécurité.\\n\\nEnfin, nous offrons des services de cloud computing pour vous aider à tirer parti des avantages du cloud. Nos experts en cloud computing peuvent vous aider à migrer vers le cloud, à optimiser vos coûts, et à tirer parti des fonctionnalités avancées des plateformes cloud.\\n\\nSi vous avez des questions ou si vous souhaitez en savoir plus sur nos services, n'hésitez pas à nous contacter. Nous serons ravis de vous aider.\\n\\n---\\n\\nJ'espère que ce texte supplémentaire répond à vos besoins pour le test de consommation de tokens. Si vous avez d'autres questions ou besoin de plus d'informations, n'hésitez pas à me le faire savoir !","hey !","2025-12-26T16:44:56Z","Bonjour ! Comment puis-je vous aider aujourd'hui ? 😊","je vais te donner un chiffre important tu vas le retenir , tu es pret ?","2025-12-26T16:45:18Z","Je suis prêt ! Donnez-moi le chiffre important, et je le retiendrai pour vous.","1996","2025-12-26T16:45:24Z","J'ai retenu le chiffre **1996**. Comment puis-je vous aider avec cette information ?",["162","163","164","165","166","167","168","169","170","171","172","173","174","175"],"localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzIyMTYsImV4cCI6MTc2Njg1ODYxNn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","W/\\"1eab-+F60koe1ruhtzP9joS1/4+QB/b4\\"",{"message_id":7,"role":"119","content":"120","created_at":"121"},{"message_id":8,"role":"122","content":"123","created_at":"121"},{"message_id":9,"role":"119","content":"124","created_at":"125"},{"message_id":10,"role":"122","content":"126","created_at":"125"},{"message_id":11,"role":"119","content":"127","created_at":"128"},{"message_id":12,"role":"122","content":"129","created_at":"128"},{"message_id":13,"role":"119","content":"130","created_at":"131"},{"message_id":14,"role":"122","content":"132","created_at":"131"},{"message_id":15,"role":"119","content":"133","created_at":"134"},{"message_id":16,"role":"122","content":"135","created_at":"134"},{"message_id":17,"role":"119","content":"136","created_at":"137"},{"message_id":18,"role":"122","content":"138","created_at":"137"},{"message_id":19,"role":"119","content":"139","created_at":"140"},{"message_id":20,"role":"122","content":"141","created_at":"140"}]
124	{"id":"msg5c740bd9db51","name":"WIBOT - Get Messages","active":true,"activeVersionId":"704bc444-e5e2-4901-9322-383bc1bd0434","isArchived":false,"createdAt":"2025-12-26T17:58:10.218Z","updatedAt":"2025-12-26T17:58:10.218Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"GET","path":"wibot/messages","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"webhook-messages","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,300],"webhookId":"wibot-messages"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst conversationId = $input.first().json.query.conversationId;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nif (!conversationId) {\\n  return [{ json: { valid: false, error: 'conversationId is required' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId, conversationId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}","notice":""},"id":"verify-jwt","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[470,300]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"if-jwt-valid","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[690,300]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-unauthorized","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[910,450]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT \\n  m.message_id,\\n  m.role,\\n  m.content,\\n  TO_CHAR(m.created_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as created_at\\nFROM messages m\\nJOIN conversations c ON m.conversation_id = c.conversation_id\\nWHERE m.conversation_id = '{{ $json.conversationId }}'::uuid\\n  AND c.user_id = {{ $json.userId }}\\nORDER BY m.created_at ASC;","options":{}},"id":"get-messages","name":"Get Messages","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[910,200],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats, retourner liste vide\\nif (!rows || rows.length === 0 || !rows[0].json.message_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      messages: []\\n    }\\n  }];\\n}\\n\\nconst messages = rows.map(row => ({\\n  message_id: row.json.message_id,\\n  role: row.json.role,\\n  content: row.json.content,\\n  created_at: row.json.created_at\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    messages\\n  }\\n}];","notice":""},"id":"format-response","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1130,200]},{"parameters":{"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"respond-success","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1350,200]}],"connections":{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Messages","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Messages":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"},"staticData":{},"pinData":{}}	[{"version":0,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","lastNodeExecuted":"5"},{"contextData":"6","nodeExecutionStack":"7","metadata":"8","waitingExecution":"9","waitingExecutionSource":"10","runtimeData":"11"},{"Webhook":"12","Verify JWT":"13","JWT Valid?":"14","Get Messages":"15","Format Response":"16","Success":"17"},"Success",{},[],{},{},{},{"version":1,"establishedAt":1766786351776,"source":"18"},["19"],["20"],["21"],["22"],["23"],["24"],"webhook",{"startTime":1766786351777,"executionIndex":0,"source":"25","hints":"26","executionTime":0,"executionStatus":"27","data":"28"},{"startTime":1766786351777,"executionIndex":1,"source":"29","hints":"30","executionTime":3,"executionStatus":"27","data":"31"},{"startTime":1766786351780,"executionIndex":2,"source":"32","hints":"33","executionTime":0,"executionStatus":"27","data":"34"},{"startTime":1766786351780,"executionIndex":3,"source":"35","hints":"36","executionTime":3,"executionStatus":"27","data":"37"},{"startTime":1766786351783,"executionIndex":4,"source":"38","hints":"39","executionTime":2,"executionStatus":"27","data":"40"},{"startTime":1766786351785,"executionIndex":5,"source":"41","hints":"42","executionTime":1,"executionStatus":"27","data":"43"},[],[],"success",{"main":"44"},["45"],["46"],{"main":"47"},["48"],[],{"main":"49"},["50"],[],{"main":"51"},["52"],["53"],{"main":"54"},["55"],[],{"main":"56"},["57"],{"previousNode":"58"},{"message":"59","location":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},["66"],{"previousNode":"67"},{"message":"59","location":"60"},["68"],{"previousNode":"69"},["70"],["71"],"Webhook","To make sure expressions after this node work, return the input items that produced each output item. <a target=\\"_blank\\" href=\\"https://docs.n8n.io/data/data-mapping/data-item-linking/item-linking-code-node/\\">More info</a>","outputPane",["72"],"Verify JWT",["73"],[],"JWT Valid?",["74","75","76","77","78","79","80","81","82","83","84","85"],"Get Messages",["86"],"Format Response",["87"],{"json":"88","pairedItem":"89"},{"json":"90","pairedItem":"91"},{"json":"90","pairedItem":"92"},{"json":"93","pairedItem":"94"},{"json":"95","pairedItem":"94"},{"json":"96","pairedItem":"94"},{"json":"97","pairedItem":"94"},{"json":"98","pairedItem":"94"},{"json":"99","pairedItem":"94"},{"json":"100","pairedItem":"94"},{"json":"101","pairedItem":"94"},{"json":"102","pairedItem":"94"},{"json":"103","pairedItem":"94"},{"json":"104","pairedItem":"94"},{"json":"105","pairedItem":"94"},{"json":"106"},{"json":"106","pairedItem":"107"},{"headers":"108","params":"109","query":"110","body":"111","webhookUrl":"112","executionMode":"113"},{"item":0},{"valid":true,"userId":1,"conversationId":"114"},{"item":0},{"item":0},{"message_id":1,"role":"115","content":"116","created_at":"117"},{"item":0},{"message_id":2,"role":"118","content":"119","created_at":"120"},{"message_id":3,"role":"115","content":"121","created_at":"122"},{"message_id":4,"role":"118","content":"123","created_at":"124"},{"message_id":5,"role":"115","content":"125","created_at":"126"},{"message_id":6,"role":"118","content":"127","created_at":"128"},{"message_id":27,"role":"115","content":"129","created_at":"130"},{"message_id":28,"role":"118","content":"131","created_at":"130"},{"message_id":29,"role":"115","content":"132","created_at":"133"},{"message_id":30,"role":"118","content":"134","created_at":"133"},{"message_id":31,"role":"115","content":"135","created_at":"136"},{"message_id":32,"role":"118","content":"137","created_at":"136"},{"success":true,"messages":"138"},{"item":0},{"host":"139","x-real-ip":"140","x-forwarded-for":"140","x-forwarded-proto":"141","connection":"142","sec-ch-ua-platform":"143","authorization":"144","user-agent":"145","accept":"146","sec-ch-ua":"147","dnt":"148","sec-ch-ua-mobile":"149","sec-fetch-site":"150","sec-fetch-mode":"151","sec-fetch-dest":"152","referer":"153","accept-encoding":"154","accept-language":"155","cookie":"156","sec-gpc":"148","if-none-match":"157"},{},{"conversationId":"114"},{},"http://localhost:5678/webhook/wibot/messages","production","550e8400-e29b-41d4-a716-446655440000","user","Bonjour WIBOT !","2025-12-24T07:42:15Z","assistant","Bonjour ! Je suis WIBOT, l'assistant IA de WIDIP. Comment puis-je t'aider aujourd'hui ?","2025-12-24T07:42:17Z","Peux-tu m'expliquer comment fonctionne PostgreSQL ?","2025-12-24T07:43:15Z","PostgreSQL est un systeme de gestion de base de donnees relationnelle (SGBDR) open source tres puissant.\\n\\n**Caracteristiques principales :**\\n- Support complet SQL\\n- Transactions ACID\\n- Extensions (comme pgcrypto pour le chiffrement)\\n- Excellent pour les charges de travail complexes\\n\\nC'est ce qu'on utilise chez WIDIP pour stocker les donnees WIBOT !","2025-12-24T07:43:20Z","Et comment faire un backup ?","2025-12-25T07:42:15Z","Pour faire un backup PostgreSQL, tu as plusieurs options :\\n\\n```bash\\n# Backup complet (dump SQL)\\npg_dump -U widip -d wibot > backup.sql\\n\\n# Backup compresse\\npg_dump -U widip -d wibot | gzip > backup.sql.gz\\n\\n# Restauration\\npsql -U widip -d wibot < backup.sql\\n```\\n\\nPour les backups automatiques, on peut utiliser un cron job ou un workflow n8n !","2025-12-25T07:42:18Z","salut","2025-12-26T17:16:30Z","Salut ! Comment puis-je vous aider aujourd'hui ?","ddadzax","2025-12-26T17:16:38Z","Bonjour ! Je ne suis pas sûr de comprendre votre demande. Pourriez-vous préciser ou reformuler votre question ? Je suis là pour vous aider avec les questions techniques ou toute autre demande liée à WIDIP.","hey","2025-12-26T17:28:13Z","Bonjour ! Comment puis-je vous aider aujourd'hui ?",["158","159","160","161","162","163","164","165","166","167","168","169"],"localhost","172.20.0.1","http","close","\\"Windows\\"","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoia2hvcmEiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NjY3NzIyMTYsImV4cCI6MTc2Njg1ODYxNn0.ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFh","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36","application/json, text/plain, */*","\\"Google Chrome\\";v=\\"143\\", \\"Chromium\\";v=\\"143\\", \\"Not A(Brand\\";v=\\"24\\"","1","?0","same-origin","cors","empty","http://localhost:5173/chat","gzip, deflate, br, zstd","fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7","rl_page_init_referrer=RudderEncrypt%3AU2FsdGVkX1%2BnxaF%2FOrHXxhG%2BF0iUrnK5WwPl3GWATWw%3D; rl_page_init_referring_domain=RudderEncrypt%3AU2FsdGVkX1%2B0hJZePG8lNcvzChFVhwuZIAH%2BuQhHVXU%3D; ph_phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo_posthog=%7B%22distinct_id%22%3A%22ff7f0f550a96ea53a4adb0ee6b5fca4386dfe54d383163a4a8fab256d2c3d0d0%236e698337-218c-4c36-ac65-182581a495b4%22%2C%22%24sesid%22%3A%5B1766525214203%2C%22019b4cf8-34da-775e-ae9c-8fcf622dd395%22%2C1766522893527%5D%2C%22%24epp%22%3Atrue%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22%24direct%22%2C%22u%22%3A%22http%3A%2F%2Flocalhost%3A5678%2Fhome%2Fworkflows%22%7D%7D; rl_anonymous_id=RudderEncrypt%3AU2FsdGVkX1%2BkaSTLcADdjqHH0yrXGAibk2iR77BwMirzs19Iyl7Po6XoRoD9FsXOnuXYzYsGvE%2FrRyPG7uQDaA%3D%3D; rl_user_id=RudderEncrypt%3AU2FsdGVkX19Gf4AdQLHt8kAQWtTVjWp8Ad5vr9oRWJKcHnlLiegmO%2FdgW2MB3x7IP%2FNiQ2u%2FcQZBn0YNXBv5XbhMA7fn73jDM63EE3v2iakvPE4dDYXyUA9LIqm1EYhVit7rI%2B2Y06oRP351%2F5pjgMBwdeNp0cgLp1csqoeoI3g%3D; rl_trait=RudderEncrypt%3AU2FsdGVkX19C1%2F8axYq7btsEj3iF1%2FzYRsZL%2BuMaT2NgI5x2UnBYVojWaUpU1rpid%2BAeWYSWCEBbV7hyjWwcPIp9ixLCfqOvO5isyq5Rh%2FPRJFXtqMN0v4XINC404YU%2FHqMlIHeyC0DcyqjvBSDAhEInNtCe%2FXDpbqy3jD2lDeo%3D; rl_session=RudderEncrypt%3AU2FsdGVkX1%2BxQI2xV%2FYHh01O1pwB%2BH042OGH2KGkMTCFY3xeavR%2BX%2FC%2BhsHwYNBU9ElksiuvBJTeHQGIwXTvPD8WvPU022IMKpYEzW0EYnJ%2BuRipsR6rSue25UcGcJm1wNf4i9CaXh4WyUZzYulTVw%3D%3D","W/\\"8c1-97WpuvK54GrQdO+AMWrIvvfcngA\\"",{"message_id":1,"role":"115","content":"116","created_at":"117"},{"message_id":2,"role":"118","content":"119","created_at":"120"},{"message_id":3,"role":"115","content":"121","created_at":"122"},{"message_id":4,"role":"118","content":"123","created_at":"124"},{"message_id":5,"role":"115","content":"125","created_at":"126"},{"message_id":6,"role":"118","content":"127","created_at":"128"},{"message_id":27,"role":"115","content":"129","created_at":"130"},{"message_id":28,"role":"118","content":"131","created_at":"130"},{"message_id":29,"role":"115","content":"132","created_at":"133"},{"message_id":30,"role":"118","content":"134","created_at":"133"},{"message_id":31,"role":"115","content":"135","created_at":"136"},{"message_id":32,"role":"118","content":"137","created_at":"136"}]
\.


--
-- Data for Name: execution_entity; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.execution_entity (id, finished, mode, "retryOf", "retrySuccessId", "startedAt", "stoppedAt", "waitTill", status, "workflowId", "deletedAt", "createdAt") FROM stdin;
74	t	webhook	\N	\N	2025-12-26 17:24:52.378+00	2025-12-26 17:24:52.395+00	\N	success	zZSHB9BHjR30ThPP	\N	2025-12-26 17:24:52.371+00
103	t	webhook	\N	\N	2025-12-26 18:02:54.689+00	2025-12-26 18:02:55.95+00	\N	success	NynEDh5rxUQL7788	\N	2025-12-26 18:02:54.679+00
75	t	webhook	\N	\N	2025-12-26 17:25:43.178+00	2025-12-26 17:25:43.195+00	\N	success	zZSHB9BHjR30ThPP	\N	2025-12-26 17:25:43.171+00
104	t	webhook	\N	\N	2025-12-26 18:02:58.139+00	2025-12-26 18:02:58.152+00	\N	success	msg5c740bd9db51	\N	2025-12-26 18:02:58.131+00
76	t	webhook	\N	\N	2025-12-26 17:25:58.376+00	2025-12-26 17:25:58.391+00	\N	success	zZSHB9BHjR30ThPP	\N	2025-12-26 17:25:58.368+00
105	t	webhook	\N	\N	2025-12-26 18:03:00.854+00	2025-12-26 18:03:00.867+00	\N	success	msg5c740bd9db51	\N	2025-12-26 18:03:00.845+00
77	t	webhook	\N	\N	2025-12-26 17:28:05.999+00	2025-12-26 17:28:06.018+00	\N	success	zZSHB9BHjR30ThPP	\N	2025-12-26 17:28:05.99+00
106	t	webhook	\N	\N	2025-12-26 18:03:02.948+00	2025-12-26 18:03:02.962+00	\N	success	msg5c740bd9db51	\N	2025-12-26 18:03:02.939+00
78	t	webhook	\N	\N	2025-12-26 17:28:06.637+00	2025-12-26 17:28:06.654+00	\N	success	c8fbjjX9ObuzBE4b	\N	2025-12-26 17:28:06.626+00
107	t	webhook	\N	\N	2025-12-26 18:03:36.175+00	2025-12-26 18:03:36.195+00	\N	success	zZSHB9BHjR30ThPP	\N	2025-12-26 18:03:36.165+00
80	t	webhook	\N	\N	2025-12-26 17:28:06.669+00	2025-12-26 17:28:06.68+00	\N	success	c8fbjjX9ObuzBE4b	\N	2025-12-26 17:28:06.664+00
79	t	webhook	\N	\N	2025-12-26 17:28:06.638+00	2025-12-26 17:28:06.689+00	\N	success	yPYTzGXVRP2JQxs8	\N	2025-12-26 17:28:06.63+00
81	t	webhook	\N	\N	2025-12-26 17:28:06.705+00	2025-12-26 17:28:06.716+00	\N	success	yPYTzGXVRP2JQxs8	\N	2025-12-26 17:28:06.699+00
109	t	webhook	\N	\N	2025-12-26 18:03:36.242+00	2025-12-26 18:03:36.262+00	\N	success	c8fbjjX9ObuzBE4b	\N	2025-12-26 18:03:36.235+00
82	t	webhook	\N	\N	2025-12-26 17:28:13.179+00	2025-12-26 17:28:13.531+00	\N	success	NynEDh5rxUQL7788	\N	2025-12-26 17:28:13.169+00
108	t	webhook	\N	\N	2025-12-26 18:03:36.241+00	2025-12-26 18:03:36.276+00	\N	success	yPYTzGXVRP2JQxs8	\N	2025-12-26 18:03:36.233+00
83	t	webhook	\N	\N	2025-12-26 17:29:58.303+00	2025-12-26 17:29:58.32+00	\N	success	yPYTzGXVRP2JQxs8	\N	2025-12-26 17:29:58.296+00
84	t	webhook	\N	\N	2025-12-26 17:30:14.381+00	2025-12-26 17:30:14.396+00	\N	success	c8fbjjX9ObuzBE4b	\N	2025-12-26 17:30:14.372+00
110	t	webhook	\N	\N	2025-12-26 18:03:36.294+00	2025-12-26 18:03:36.307+00	\N	success	c8fbjjX9ObuzBE4b	\N	2025-12-26 18:03:36.281+00
85	t	webhook	\N	\N	2025-12-26 17:34:12.976+00	2025-12-26 17:34:13.445+00	\N	success	NynEDh5rxUQL7788	\N	2025-12-26 17:34:12.968+00
111	t	webhook	\N	\N	2025-12-26 18:03:36.311+00	2025-12-26 18:03:36.325+00	\N	success	yPYTzGXVRP2JQxs8	\N	2025-12-26 18:03:36.294+00
86	t	webhook	\N	\N	2025-12-26 17:46:29.897+00	2025-12-26 17:46:29.923+00	\N	success	yPYTzGXVRP2JQxs8	\N	2025-12-26 17:46:29.878+00
112	t	webhook	\N	\N	2025-12-26 18:03:36.321+00	2025-12-26 18:03:36.336+00	\N	success	msg5c740bd9db51	\N	2025-12-26 18:03:36.301+00
87	t	webhook	\N	\N	2025-12-26 18:00:56.373+00	2025-12-26 18:00:56.4+00	\N	success	msg5c740bd9db51	\N	2025-12-26 18:00:56.353+00
113	t	webhook	\N	\N	2025-12-26 18:03:36.352+00	2025-12-26 18:03:36.364+00	\N	success	msg5c740bd9db51	\N	2025-12-26 18:03:36.346+00
88	t	webhook	\N	\N	2025-12-26 18:01:10.562+00	2025-12-26 18:01:10.607+00	\N	success	zZSHB9BHjR30ThPP	\N	2025-12-26 18:01:10.553+00
114	t	webhook	\N	\N	2025-12-26 18:03:37.972+00	2025-12-26 18:03:37.984+00	\N	success	msg5c740bd9db51	\N	2025-12-26 18:03:37.966+00
89	t	webhook	\N	\N	2025-12-26 18:01:28.392+00	2025-12-26 18:01:28.416+00	\N	success	zZSHB9BHjR30ThPP	\N	2025-12-26 18:01:28.382+00
90	t	webhook	\N	\N	2025-12-26 18:01:43.406+00	2025-12-26 18:01:43.429+00	\N	success	msg5c740bd9db51	\N	2025-12-26 18:01:43.399+00
115	t	webhook	\N	\N	2025-12-26 18:03:38.416+00	2025-12-26 18:03:38.427+00	\N	success	msg5c740bd9db51	\N	2025-12-26 18:03:38.409+00
91	t	webhook	\N	\N	2025-12-26 18:01:51.363+00	2025-12-26 18:01:51.379+00	\N	success	yPYTzGXVRP2JQxs8	\N	2025-12-26 18:01:51.356+00
116	t	webhook	\N	\N	2025-12-26 18:03:38.771+00	2025-12-26 18:03:38.783+00	\N	success	msg5c740bd9db51	\N	2025-12-26 18:03:38.763+00
92	t	webhook	\N	\N	2025-12-26 18:01:58.34+00	2025-12-26 18:01:58.354+00	\N	success	msg5c740bd9db51	\N	2025-12-26 18:01:58.335+00
118	t	webhook	\N	\N	2025-12-26 21:59:08.271+00	2025-12-26 21:59:08.3+00	\N	success	c8fbjjX9ObuzBE4b	\N	2025-12-26 21:59:08.26+00
93	t	webhook	\N	\N	2025-12-26 18:02:28.575+00	2025-12-26 18:02:28.6+00	\N	success	yPYTzGXVRP2JQxs8	\N	2025-12-26 18:02:28.568+00
94	t	webhook	\N	\N	2025-12-26 18:02:28.589+00	2025-12-26 18:02:28.608+00	\N	success	c8fbjjX9ObuzBE4b	\N	2025-12-26 18:02:28.584+00
117	t	webhook	\N	\N	2025-12-26 21:59:08.269+00	2025-12-26 21:59:08.306+00	\N	success	yPYTzGXVRP2JQxs8	\N	2025-12-26 21:59:08.253+00
95	t	webhook	\N	\N	2025-12-26 18:02:28.638+00	2025-12-26 18:02:28.658+00	\N	success	yPYTzGXVRP2JQxs8	\N	2025-12-26 18:02:28.628+00
97	t	webhook	\N	\N	2025-12-26 18:02:28.651+00	2025-12-26 18:02:28.67+00	\N	success	c8fbjjX9ObuzBE4b	\N	2025-12-26 18:02:28.632+00
96	t	webhook	\N	\N	2025-12-26 18:02:28.639+00	2025-12-26 18:02:28.68+00	\N	success	msg5c740bd9db51	\N	2025-12-26 18:02:28.63+00
119	t	webhook	\N	\N	2025-12-26 21:59:08.347+00	2025-12-26 21:59:08.374+00	\N	success	c8fbjjX9ObuzBE4b	\N	2025-12-26 21:59:08.335+00
120	t	webhook	\N	\N	2025-12-26 21:59:08.348+00	2025-12-26 21:59:08.385+00	\N	success	yPYTzGXVRP2JQxs8	\N	2025-12-26 21:59:08.339+00
98	t	webhook	\N	\N	2025-12-26 18:02:28.702+00	2025-12-26 18:02:28.715+00	\N	success	msg5c740bd9db51	\N	2025-12-26 18:02:28.695+00
121	t	webhook	\N	\N	2025-12-26 21:59:08.367+00	2025-12-26 21:59:08.392+00	\N	success	msg5c740bd9db51	\N	2025-12-26 21:59:08.34+00
99	t	webhook	\N	\N	2025-12-26 18:02:30.592+00	2025-12-26 18:02:30.605+00	\N	success	msg5c740bd9db51	\N	2025-12-26 18:02:30.586+00
122	t	webhook	\N	\N	2025-12-26 21:59:08.411+00	2025-12-26 21:59:08.423+00	\N	success	msg5c740bd9db51	\N	2025-12-26 21:59:08.405+00
100	t	webhook	\N	\N	2025-12-26 18:02:31.524+00	2025-12-26 18:02:31.539+00	\N	success	msg5c740bd9db51	\N	2025-12-26 18:02:31.519+00
123	t	webhook	\N	\N	2025-12-26 21:59:11.08+00	2025-12-26 21:59:11.092+00	\N	success	msg5c740bd9db51	\N	2025-12-26 21:59:11.071+00
101	t	webhook	\N	\N	2025-12-26 18:02:33.489+00	2025-12-26 18:02:33.501+00	\N	success	msg5c740bd9db51	\N	2025-12-26 18:02:33.481+00
102	t	webhook	\N	\N	2025-12-26 18:02:37.362+00	2025-12-26 18:02:37.374+00	\N	success	msg5c740bd9db51	\N	2025-12-26 18:02:37.354+00
124	t	webhook	\N	\N	2025-12-26 21:59:11.773+00	2025-12-26 21:59:11.786+00	\N	success	msg5c740bd9db51	\N	2025-12-26 21:59:11.768+00
125	t	webhook	\N	\N	2025-12-26 21:59:12.873+00	2025-12-26 21:59:12.884+00	\N	success	msg5c740bd9db51	\N	2025-12-26 21:59:12.865+00
\.


--
-- Data for Name: execution_metadata; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.execution_metadata (id, "executionId", key, value) FROM stdin;
\.


--
-- Data for Name: folder; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.folder (id, name, "parentFolderId", "projectId", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: folder_tag; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.folder_tag ("folderId", "tagId") FROM stdin;
\.


--
-- Data for Name: insights_by_period; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.insights_by_period (id, "metaId", type, value, "periodUnit", "periodStart") FROM stdin;
2	4	3	2	0	2025-12-26 08:00:00+00
3	2	2	1	0	2025-12-26 07:00:00+00
4	2	1	42	0	2025-12-26 08:00:00+00
6	3	1	26	0	2025-12-26 07:00:00+00
7	1	3	2	0	2025-12-26 07:00:00+00
8	5	2	2	0	2025-12-26 08:00:00+00
9	2	1	21	0	2025-12-26 07:00:00+00
10	1	1	75	0	2025-12-26 07:00:00+00
11	3	3	5	0	2025-12-26 07:00:00+00
12	5	1	20	0	2025-12-26 08:00:00+00
13	4	1	33	0	2025-12-26 08:00:00+00
14	2	2	2	0	2025-12-26 08:00:00+00
1	6	2	17	0	2025-12-26 08:00:00+00
5	6	1	209095	0	2025-12-26 08:00:00+00
17	6	2	1	0	2025-12-26 09:00:00+00
18	6	1	19737	0	2025-12-26 09:00:00+00
19	5	2	6	0	2025-12-26 12:00:00+00
20	6	1	26934	0	2025-12-26 12:00:00+00
21	6	2	6	0	2025-12-26 12:00:00+00
22	5	1	61	0	2025-12-26 12:00:00+00
23	10	2	2	0	2025-12-26 16:00:00+00
24	2	1	20	0	2025-12-26 16:00:00+00
25	9	1	12610	0	2025-12-26 16:00:00+00
26	10	1	43	0	2025-12-26 16:00:00+00
27	2	2	1	0	2025-12-26 16:00:00+00
28	9	2	8	0	2025-12-26 16:00:00+00
29	2	1	71	0	2025-12-26 17:00:00+00
30	16	1	37	0	2025-12-26 17:00:00+00
31	16	2	3	0	2025-12-26 17:00:00+00
32	9	1	1440	0	2025-12-26 17:00:00+00
33	14	2	1	0	2025-12-26 18:00:00+00
34	14	1	1259	0	2025-12-26 18:00:00+00
35	2	2	6	0	2025-12-26 17:00:00+00
36	16	2	4	0	2025-12-26 18:00:00+00
37	15	1	95	0	2025-12-26 18:00:00+00
38	13	2	3	0	2025-12-26 18:00:00+00
39	13	2	4	0	2025-12-26 17:00:00+00
40	15	2	4	0	2025-12-26 17:00:00+00
41	14	2	2	0	2025-12-26 17:00:00+00
42	9	2	5	0	2025-12-26 17:00:00+00
43	16	1	51	0	2025-12-26 18:00:00+00
44	10	2	5	0	2025-12-26 17:00:00+00
45	12	1	11	0	2025-12-26 17:00:00+00
46	15	2	5	0	2025-12-26 18:00:00+00
47	13	1	60	0	2025-12-26 17:00:00+00
48	18	1	224	0	2025-12-26 18:00:00+00
49	18	2	17	0	2025-12-26 18:00:00+00
50	13	1	83	0	2025-12-26 18:00:00+00
51	12	2	2	0	2025-12-26 17:00:00+00
52	14	1	816	0	2025-12-26 17:00:00+00
53	15	1	91	0	2025-12-26 17:00:00+00
54	10	1	54	0	2025-12-26 17:00:00+00
\.


--
-- Data for Name: insights_metadata; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.insights_metadata ("metaId", "workflowId", "projectId", "workflowName", "projectName") FROM stdin;
3	\N	sxOW4Z7kldKTFN4J	WIBOT - Get Conversations	Maxime Ripouteau <maximeripouteau@gmail.com>
1	\N	sxOW4Z7kldKTFN4J	WIBOT - Auth Login	Maxime Ripouteau <maximeripouteau@gmail.com>
6	\N	sxOW4Z7kldKTFN4J	WIBOT - Chat Main	Maxime Ripouteau <maximeripouteau@gmail.com>
4	\N	sxOW4Z7kldKTFN4J	WIBOT - Get Conversations	Maxime Ripouteau <maximeripouteau@gmail.com>
2	\N	sxOW4Z7kldKTFN4J	WIBOT - Auth Login	Maxime Ripouteau <maximeripouteau@gmail.com>
10	\N	sxOW4Z7kldKTFN4J	WIBOT - Get Conversations	Maxime Ripouteau <maximeripouteau@gmail.com>
12	\N	sxOW4Z7kldKTFN4J	WIBOT - Get User Tokens	Maxime Ripouteau <maximeripouteau@gmail.com>
5	\N	sxOW4Z7kldKTFN4J	WIBOT - Get Conversations	Maxime Ripouteau <maximeripouteau@gmail.com>
9	\N	sxOW4Z7kldKTFN4J	WIBOT - Chat Main	Maxime Ripouteau <maximeripouteau@gmail.com>
18	msg5c740bd9db51	sxOW4Z7kldKTFN4J	WIBOT - Get Messages	Maxime Ripouteau <maximeripouteau@gmail.com>
13	zZSHB9BHjR30ThPP	sxOW4Z7kldKTFN4J	WIBOT - Auth Login	Maxime Ripouteau <maximeripouteau@gmail.com>
15	yPYTzGXVRP2JQxs8	sxOW4Z7kldKTFN4J	WIBOT - Get Conversations	Maxime Ripouteau <maximeripouteau@gmail.com>
16	c8fbjjX9ObuzBE4b	sxOW4Z7kldKTFN4J	WIBOT - Get User Tokens	Maxime Ripouteau <maximeripouteau@gmail.com>
14	NynEDh5rxUQL7788	sxOW4Z7kldKTFN4J	WIBOT - Chat Main	Maxime Ripouteau <maximeripouteau@gmail.com>
\.


--
-- Data for Name: insights_raw; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.insights_raw (id, "metaId", type, value, "timestamp") FROM stdin;
233	16	2	1	2025-12-26 21:59:08+00
234	16	1	22	2025-12-26 21:59:08+00
235	15	2	1	2025-12-26 21:59:08+00
236	15	1	34	2025-12-26 21:59:08+00
237	16	2	1	2025-12-26 21:59:08+00
238	16	1	23	2025-12-26 21:59:08+00
239	15	2	1	2025-12-26 21:59:08+00
240	15	1	22	2025-12-26 21:59:08+00
241	18	2	1	2025-12-26 21:59:08+00
242	18	1	17	2025-12-26 21:59:08+00
243	18	2	1	2025-12-26 21:59:08+00
244	18	1	10	2025-12-26 21:59:08+00
245	18	2	1	2025-12-26 21:59:11+00
246	18	1	10	2025-12-26 21:59:11+00
247	18	2	1	2025-12-26 21:59:12+00
248	18	1	10	2025-12-26 21:59:12+00
249	18	2	1	2025-12-26 21:59:13+00
250	18	1	9	2025-12-26 21:59:13+00
\.


--
-- Data for Name: installed_nodes; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.installed_nodes (name, type, "latestVersion", package) FROM stdin;
\.


--
-- Data for Name: installed_packages; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.installed_packages ("packageName", "installedVersion", "authorName", "authorEmail", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: invalid_auth_token; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.invalid_auth_token (token, "expiresAt") FROM stdin;
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.messages (message_id, conversation_id, user_id, role, content, tokens, attachments, created_at) FROM stdin;
1	550e8400-e29b-41d4-a716-446655440000	1	user	Bonjour WIBOT !	10	\N	2025-12-24 07:42:15.25093
2	550e8400-e29b-41d4-a716-446655440000	1	assistant	Bonjour ! Je suis WIBOT, l'assistant IA de WIDIP. Comment puis-je t'aider aujourd'hui ?	25	\N	2025-12-24 07:42:17.253765
3	550e8400-e29b-41d4-a716-446655440000	1	user	Peux-tu m'expliquer comment fonctionne PostgreSQL ?	15	\N	2025-12-24 07:43:15.25556
4	550e8400-e29b-41d4-a716-446655440000	1	assistant	PostgreSQL est un systeme de gestion de base de donnees relationnelle (SGBDR) open source tres puissant.\n\n**Caracteristiques principales :**\n- Support complet SQL\n- Transactions ACID\n- Extensions (comme pgcrypto pour le chiffrement)\n- Excellent pour les charges de travail complexes\n\nC'est ce qu'on utilise chez WIDIP pour stocker les donnees WIBOT !	95	\N	2025-12-24 07:43:20.257993
5	550e8400-e29b-41d4-a716-446655440000	1	user	Et comment faire un backup ?	8	\N	2025-12-25 07:42:15.259608
6	550e8400-e29b-41d4-a716-446655440000	1	assistant	Pour faire un backup PostgreSQL, tu as plusieurs options :\n\n```bash\n# Backup complet (dump SQL)\npg_dump -U widip -d wibot > backup.sql\n\n# Backup compresse\npg_dump -U widip -d wibot | gzip > backup.sql.gz\n\n# Restauration\npsql -U widip -d wibot < backup.sql\n```\n\nPour les backups automatiques, on peut utiliser un cron job ou un workflow n8n !	120	\N	2025-12-25 07:42:18.262342
7	3cc2c8db-afef-4637-accc-31d259f53857	1	user	saluty	2	\N	2025-12-26 16:43:14.796305
8	3cc2c8db-afef-4637-accc-31d259f53857	1	assistant	Bonjour ! Comment puis-je vous aider aujourd'hui ?	13	\N	2025-12-26 16:43:14.806041
9	3cc2c8db-afef-4637-accc-31d259f53857	1	user	tout va bien ?	4	\N	2025-12-26 16:43:24.308223
10	3cc2c8db-afef-4637-accc-31d259f53857	1	assistant	Tout va très bien, merci de demander ! Je suis prêt à vous aider avec vos questions techniques. Comment puis-je vous assister aujourd'hui ?	35	\N	2025-12-26 16:43:24.31238
11	3cc2c8db-afef-4637-accc-31d259f53857	1	user	genere un max de text je test la conso token	11	\N	2025-12-26 16:43:40.249355
12	3cc2c8db-afef-4637-accc-31d259f53857	1	assistant	Je comprends que vous souhaitez tester la consommation de tokens. Voici un texte plus long pour vous aider dans votre test :\n\n---\n\nChez WIDIP, nous sommes une entreprise française de services informatiques spécialisée dans l'accompagnement des entreprises dans leur transformation numérique. Notre mission est de fournir des solutions technologiques innovantes et sur mesure pour répondre aux besoins spécifiques de nos clients.\n\nNous offrons une large gamme de services, allant du développement de logiciels sur mesure à l'infogérance, en passant par la cybersécurité et le cloud computing. Notre équipe d'experts est composée de professionnels qualifiés et passionnés, toujours prêts à relever les défis technologiques les plus complexes.\n\nChez WIDIP, nous croyons en l'importance de la collaboration et de la communication. Nous travaillons en étroite collaboration avec nos clients pour comprendre leurs besoins et leurs attentes, et nous nous engageons à fournir des solutions qui non seulement répondent à ces besoins, mais qui les dépassent.\n\nNous sommes également convaincus que la formation et le développement des compétences sont essentiels pour rester à la pointe de la technologie. C'est pourquoi nous investissons continuellement dans la formation de nos employés et dans l'acquisition de nouvelles compétences.\n\nEn choisissant WIDIP, vous bénéficiez de notre expertise, de notre engagement et de notre passion pour la technologie. Nous sommes là pour vous accompagner à chaque étape de votre transformation numérique, en vous fournissant des solutions qui vous permettent de tirer le meilleur parti de la technologie.\n\nSi vous avez des questions ou si vous souhaitez en savoir plus sur nos services, n'hésitez pas à nous contacter. Nous serons ravis de vous aider.\n\n---\n\nJ'espère que ce texte répond à vos besoins pour le test de consommation de tokens. Si vous avez d'autres questions ou besoin de plus d'informations, n'hésitez pas à me le faire savoir !	493	\N	2025-12-26 16:43:40.253834
13	3cc2c8db-afef-4637-accc-31d259f53857	1	user	encore	2	\N	2025-12-26 16:43:51.129495
14	3cc2c8db-afef-4637-accc-31d259f53857	1	assistant	Bien sûr ! Voici un texte encore plus long pour votre test de consommation de tokens :\n\n---\n\nChez WIDIP, nous sommes une entreprise française de services informatiques spécialisée dans l'accompagnement des entreprises dans leur transformation numérique. Notre mission est de fournir des solutions technologiques innovantes et sur mesure pour répondre aux besoins spécifiques de nos clients.\n\nNous offrons une large gamme de services, allant du développement de logiciels sur mesure à l'infogérance, en passant par la cybersécurité et le cloud computing. Notre équipe d'experts est composée de professionnels qualifiés et passionnés, toujours prêts à relever les défis technologiques les plus complexes.\n\nChez WIDIP, nous croyons en l'importance de la collaboration et de la communication. Nous travaillons en étroite collaboration avec nos clients pour comprendre leurs besoins et leurs attentes, et nous nous engageons à fournir des solutions qui non seulement répondent à ces besoins, mais qui les dépassent.\n\nNous sommes également convaincus que la formation et le développement des compétences sont essentiels pour rester à la pointe de la technologie. C'est pourquoi nous investissons continuellement dans la formation de nos employés et dans l'acquisition de nouvelles compétences.\n\nEn choisissant WIDIP, vous bénéficiez de notre expertise, de notre engagement et de notre passion pour la technologie. Nous sommes là pour vous accompagner à chaque étape de votre transformation numérique, en vous fournissant des solutions qui vous permettent de tirer le meilleur parti de la technologie.\n\nSi vous avez des questions ou si vous souhaitez en savoir plus sur nos services, n'hésitez pas à nous contacter. Nous serons ravis de vous aider.\n\n---\n\nVoici un exemple de code en Python pour illustrer nos compétences en développement de logiciels :\n\n```python\n# Exemple de code Python pour calculer la factorielle d'un nombre\n\ndef factorielle(n):\n    if n == 0:\n        return 1\n    else:\n        return n * factorielle(n - 1)\n\n# Exemple d'utilisation\nnombre = 5\nresultat = factorielle(nombre)\nprint(f"La factorielle de {nombre} est {resultat}")\n```\n\nChez WIDIP, nous utilisons des technologies de pointe pour développer des solutions robustes et évolutives. Nos développeurs sont expérimentés dans divers langages de programmation, tels que Python, Java, C++, et bien d'autres.\n\nNous mettons également un point d'honneur à suivre les meilleures pratiques en matière de développement logiciel, telles que la programmation orientée objet, les tests unitaires, et la documentation du code. Nous croyons que ces pratiques sont essentielles pour garantir la qualité et la maintenabilité de nos solutions.\n\nEn plus du développement de logiciels, nous offrons également des services d'infogérance pour aider nos clients à gérer leurs infrastructures informatiques. Nos experts en infogérance peuvent vous aider à optimiser vos systèmes, à améliorer leur sécurité, et à assurer leur disponibilité.\n\nNous proposons également des services de cybersécurité pour protéger vos données et vos systèmes contre les cybermenaces. Nos experts en cybersécurité peuvent vous aider à mettre en place des mesures de sécurité efficaces, à effectuer des audits de sécurité, et à répondre aux incidents de sécurité.\n\nEnfin, nous offrons des services de cloud computing pour vous aider à tirer parti des avantages du cloud. Nos experts en cloud computing peuvent vous aider à migrer vers le cloud, à optimiser vos coûts, et à tirer parti des fonctionnalités avancées des plateformes cloud.\n\nSi vous avez des questions ou si vous souhaitez en savoir plus sur nos services, n'hésitez pas à nous contacter. Nous serons ravis de vous aider.\n\n---\n\nJ'espère que ce texte supplémentaire répond à vos besoins pour le test de consommation de tokens. Si vous avez d'autres questions ou besoin de plus d'informations, n'hésitez pas à me le faire savoir !	979	\N	2025-12-26 16:43:51.132831
15	3cc2c8db-afef-4637-accc-31d259f53857	1	user	hey !	2	\N	2025-12-26 16:44:56.142884
16	3cc2c8db-afef-4637-accc-31d259f53857	1	assistant	Bonjour ! Comment puis-je vous aider aujourd'hui ? 😊	14	\N	2025-12-26 16:44:56.146668
17	3cc2c8db-afef-4637-accc-31d259f53857	1	user	je vais te donner un chiffre important tu vas le retenir , tu es pret ?	18	\N	2025-12-26 16:45:18.945766
18	3cc2c8db-afef-4637-accc-31d259f53857	1	assistant	Je suis prêt ! Donnez-moi le chiffre important, et je le retiendrai pour vous.	20	\N	2025-12-26 16:45:18.949993
19	3cc2c8db-afef-4637-accc-31d259f53857	1	user	1996	1	\N	2025-12-26 16:45:24.687919
20	3cc2c8db-afef-4637-accc-31d259f53857	1	assistant	J'ai retenu le chiffre **1996**. Comment puis-je vous aider avec cette information ?	21	\N	2025-12-26 16:45:24.691197
21	963eb9f1-fdcc-4cd5-918b-29fae40c17a0	1	user	quel est le chiffre important que je t'ai donné ?	13	\N	2025-12-26 16:45:37.422543
22	963eb9f1-fdcc-4cd5-918b-29fae40c17a0	1	assistant	Je n'ai pas de mémoire persistante entre nos interactions, donc je ne peux pas me souvenir des informations partagées lors de nos précédentes conversations. Si vous me donnez à nouveau le chiffre important, je serai ravi de vous aider avec celui-ci.\n\nN'hésitez pas à me le communiquer !	72	\N	2025-12-26 16:45:37.42646
23	963eb9f1-fdcc-4cd5-918b-29fae40c17a0	1	user	salut	2	\N	2025-12-26 17:13:49.534376
24	963eb9f1-fdcc-4cd5-918b-29fae40c17a0	1	assistant	Salut ! Comment puis-je vous aider aujourd'hui ? 😊	13	\N	2025-12-26 17:13:49.537972
25	963eb9f1-fdcc-4cd5-918b-29fae40c17a0	1	user	salut	2	\N	2025-12-26 17:14:33.871186
26	963eb9f1-fdcc-4cd5-918b-29fae40c17a0	1	assistant	Bonjour ! Comment puis-je vous aider aujourd'hui ? 😊	14	\N	2025-12-26 17:14:33.875751
27	550e8400-e29b-41d4-a716-446655440000	1	user	salut	2	\N	2025-12-26 17:16:30.957333
28	550e8400-e29b-41d4-a716-446655440000	1	assistant	Salut ! Comment puis-je vous aider aujourd'hui ?	12	\N	2025-12-26 17:16:30.961912
29	550e8400-e29b-41d4-a716-446655440000	1	user	ddadzax	2	\N	2025-12-26 17:16:38.478597
30	550e8400-e29b-41d4-a716-446655440000	1	assistant	Bonjour ! Je ne suis pas sûr de comprendre votre demande. Pourriez-vous préciser ou reformuler votre question ? Je suis là pour vous aider avec les questions techniques ou toute autre demande liée à WIDIP.	52	\N	2025-12-26 17:16:38.481751
31	550e8400-e29b-41d4-a716-446655440000	1	user	hey	1	\N	2025-12-26 17:28:13.519543
32	550e8400-e29b-41d4-a716-446655440000	1	assistant	Bonjour ! Comment puis-je vous aider aujourd'hui ?	13	\N	2025-12-26 17:28:13.523475
33	963eb9f1-fdcc-4cd5-918b-29fae40c17a0	1	user	dsf ça va ?	3	\N	2025-12-26 17:34:13.433144
34	963eb9f1-fdcc-4cd5-918b-29fae40c17a0	1	assistant	Bonjour ! Je vais très bien, merci de demander. 😊\n\nComment puis-je vous aider aujourd'hui ?	23	\N	2025-12-26 17:34:13.437395
35	419ba4c9-f14d-4af2-83b3-ba2399c17ffb	1	user	tu es tristes ?	4	\N	2025-12-26 18:02:55.929771
36	419ba4c9-f14d-4af2-83b3-ba2399c17ffb	1	assistant	Non, je ne suis pas triste. En tant qu'IA, je n'ai pas de sentiments ou d'émotions. Mon rôle est de vous aider avec vos questions techniques et de fournir des réponses claires et professionnelles. Comment puis-je vous aider aujourd'hui ?	60	\N	2025-12-26 18:02:55.939461
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.migrations (id, "timestamp", name) FROM stdin;
1	1587669153312	InitialMigration1587669153312
2	1589476000887	WebhookModel1589476000887
3	1594828256133	CreateIndexStoppedAt1594828256133
4	1607431743768	MakeStoppedAtNullable1607431743768
5	1611144599516	AddWebhookId1611144599516
6	1617270242566	CreateTagEntity1617270242566
7	1620824779533	UniqueWorkflowNames1620824779533
8	1626176912946	AddwaitTill1626176912946
9	1630419189837	UpdateWorkflowCredentials1630419189837
10	1644422880309	AddExecutionEntityIndexes1644422880309
11	1646834195327	IncreaseTypeVarcharLimit1646834195327
12	1646992772331	CreateUserManagement1646992772331
13	1648740597343	LowerCaseUserEmail1648740597343
14	1652254514002	CommunityNodes1652254514002
15	1652367743993	AddUserSettings1652367743993
16	1652905585850	AddAPIKeyColumn1652905585850
17	1654090467022	IntroducePinData1654090467022
18	1658932090381	AddNodeIds1658932090381
19	1659902242948	AddJsonKeyPinData1659902242948
20	1660062385367	CreateCredentialsUserRole1660062385367
21	1663755770893	CreateWorkflowsEditorRole1663755770893
22	1664196174001	WorkflowStatistics1664196174001
23	1665484192212	CreateCredentialUsageTable1665484192212
24	1665754637025	RemoveCredentialUsageTable1665754637025
25	1669739707126	AddWorkflowVersionIdColumn1669739707126
26	1669823906995	AddTriggerCountColumn1669823906995
27	1671535397530	MessageEventBusDestinations1671535397530
28	1671726148421	RemoveWorkflowDataLoadedFlag1671726148421
29	1673268682475	DeleteExecutionsWithWorkflows1673268682475
30	1674138566000	AddStatusToExecutions1674138566000
31	1674509946020	CreateLdapEntities1674509946020
32	1675940580449	PurgeInvalidWorkflowConnections1675940580449
33	1676996103000	MigrateExecutionStatus1676996103000
34	1677236854063	UpdateRunningExecutionStatus1677236854063
35	1677501636754	CreateVariables1677501636754
36	1679416281778	CreateExecutionMetadataTable1679416281778
37	1681134145996	AddUserActivatedProperty1681134145996
38	1681134145997	RemoveSkipOwnerSetup1681134145997
39	1690000000000	MigrateIntegerKeysToString1690000000000
40	1690000000020	SeparateExecutionData1690000000020
41	1690000000030	RemoveResetPasswordColumns1690000000030
42	1690000000030	AddMfaColumns1690000000030
43	1690787606731	AddMissingPrimaryKeyOnExecutionData1690787606731
44	1691088862123	CreateWorkflowNameIndex1691088862123
45	1692967111175	CreateWorkflowHistoryTable1692967111175
46	1693491613982	ExecutionSoftDelete1693491613982
47	1693554410387	DisallowOrphanExecutions1693554410387
48	1694091729095	MigrateToTimestampTz1694091729095
49	1695128658538	AddWorkflowMetadata1695128658538
50	1695829275184	ModifyWorkflowHistoryNodesAndConnections1695829275184
51	1700571993961	AddGlobalAdminRole1700571993961
52	1705429061930	DropRoleMapping1705429061930
53	1711018413374	RemoveFailedExecutionStatus1711018413374
54	1711390882123	MoveSshKeysToDatabase1711390882123
55	1712044305787	RemoveNodesAccess1712044305787
56	1714133768519	CreateProject1714133768519
57	1714133768521	MakeExecutionStatusNonNullable1714133768521
58	1717498465931	AddActivatedAtUserSetting1717498465931
59	1720101653148	AddConstraintToExecutionMetadata1720101653148
60	1721377157740	FixExecutionMetadataSequence1721377157740
61	1723627610222	CreateInvalidAuthTokenTable1723627610222
62	1723796243146	RefactorExecutionIndices1723796243146
63	1724753530828	CreateAnnotationTables1724753530828
64	1724951148974	AddApiKeysTable1724951148974
65	1726606152711	CreateProcessedDataTable1726606152711
66	1727427440136	SeparateExecutionCreationFromStart1727427440136
67	1728659839644	AddMissingPrimaryKeyOnAnnotationTagMapping1728659839644
68	1729607673464	UpdateProcessedDataValueColumnToText1729607673464
69	1729607673469	AddProjectIcons1729607673469
70	1730386903556	CreateTestDefinitionTable1730386903556
71	1731404028106	AddDescriptionToTestDefinition1731404028106
72	1731582748663	MigrateTestDefinitionKeyToString1731582748663
73	1732271325258	CreateTestMetricTable1732271325258
74	1732549866705	CreateTestRun1732549866705
75	1733133775640	AddMockedNodesColumnToTestDefinition1733133775640
76	1734479635324	AddManagedColumnToCredentialsTable1734479635324
77	1736172058779	AddStatsColumnsToTestRun1736172058779
78	1736947513045	CreateTestCaseExecutionTable1736947513045
79	1737715421462	AddErrorColumnsToTestRuns1737715421462
80	1738709609940	CreateFolderTable1738709609940
81	1739549398681	CreateAnalyticsTables1739549398681
82	1740445074052	UpdateParentFolderIdColumn1740445074052
83	1741167584277	RenameAnalyticsToInsights1741167584277
84	1742918400000	AddScopesColumnToApiKeys1742918400000
85	1745322634000	ClearEvaluation1745322634000
86	1745587087521	AddWorkflowStatisticsRootCount1745587087521
87	1745934666076	AddWorkflowArchivedColumn1745934666076
88	1745934666077	DropRoleTable1745934666077
89	1747824239000	AddProjectDescriptionColumn1747824239000
90	1750252139166	AddLastActiveAtColumnToUser1750252139166
91	1750252139166	AddScopeTables1750252139166
92	1750252139167	AddRolesTables1750252139167
93	1750252139168	LinkRoleToUserTable1750252139168
94	1750252139170	RemoveOldRoleColumn1750252139170
95	1752669793000	AddInputsOutputsToTestCaseExecution1752669793000
96	1753953244168	LinkRoleToProjectRelationTable1753953244168
97	1754475614601	CreateDataStoreTables1754475614601
98	1754475614602	ReplaceDataStoreTablesWithDataTables1754475614602
99	1756906557570	AddTimestampsToRoleAndRoleIndexes1756906557570
100	1758731786132	AddAudienceColumnToApiKeys1758731786132
101	1758794506893	AddProjectIdToVariableTable1758794506893
102	1759399811000	ChangeValueTypesForInsights1759399811000
103	1760019379982	CreateChatHubTables1760019379982
104	1760020000000	CreateChatHubAgentTable1760020000000
105	1760020838000	UniqueRoleNames1760020838000
106	1760116750277	CreateOAuthEntities1760116750277
107	1760314000000	CreateWorkflowDependencyTable1760314000000
108	1760965142113	DropUnusedChatHubColumns1760965142113
109	1761047826451	AddWorkflowVersionColumn1761047826451
110	1761655473000	ChangeDependencyInfoToJson1761655473000
111	1761773155024	AddAttachmentsToChatHubMessages1761773155024
112	1761830340990	AddToolsColumnToChatHubTables1761830340990
113	1762177736257	AddWorkflowDescriptionColumn1762177736257
114	1762763704614	BackfillMissingWorkflowHistoryRecords1762763704614
115	1762771264000	ChangeDefaultForIdInUserTable1762771264000
116	1762771954619	AddIsGlobalColumnToCredentialsTable1762771954619
117	1762847206508	AddWorkflowHistoryAutoSaveFields1762847206508
118	1763047800000	AddActiveVersionIdColumn1763047800000
119	1763572724000	ChangeOAuthStateColumnToUnboundedVarchar1763572724000
120	1763716655000	CreateBinaryDataTable1763716655000
\.


--
-- Data for Name: n8n_chat_histories; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.n8n_chat_histories (id, session_id, message) FROM stdin;
1	1_7fbd5214-e6f4-4045-accf-c6ec9c64a40a	{"type": "human", "content": "salut , comment peux tu m'aider aujourd'ui", "additional_kwargs": {}, "response_metadata": {}}
2	1_7fbd5214-e6f4-4045-accf-c6ec9c64a40a	{"type": "ai", "content": "Bonjour ! Je suis ravi de pouvoir vous aider aujourd'hui. En tant qu'assistant IA de WIDIP, je peux vous aider avec :\\n\\n- Des questions techniques sur nos projets et technologies\\n- Des conseils sur les bonnes pratiques de développement\\n- De l'aide pour résoudre des problèmes techniques\\n- Des informations sur les processus et outils internes\\n\\nN'hésitez pas à me poser votre question, et je ferai de mon mieux pour vous fournir une réponse claire et utile.\\n\\nQu'aimeriez-vous savoir aujourd'hui ?", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
3	1_7fbd5214-e6f4-4045-accf-c6ec9c64a40a	{"type": "human", "content": "on va tester ta memoir , si je cite un oeuvre ,peux tu me la redonner au message suivant , exemple : harry potter", "additional_kwargs": {}, "response_metadata": {}}
4	1_7fbd5214-e6f4-4045-accf-c6ec9c64a40a	{"type": "ai", "content": "Bien sûr ! Je vais essayer de retenir cette information. Vous pouvez me citer une œuvre, et je ferai de mon mieux pour vous la rappeler dans notre prochain échange.\\n\\nPar exemple, si vous me dites : \\"Harry Potter\\", je noterai cette information et je pourrai vous la rappeler plus tard.\\n\\nQuelle œuvre souhaitez-vous que je retienne pour notre test ?", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
5	1_7fbd5214-e6f4-4045-accf-c6ec9c64a40a	{"type": "human", "content": "3+3 ?", "additional_kwargs": {}, "response_metadata": {}}
6	1_7fbd5214-e6f4-4045-accf-c6ec9c64a40a	{"type": "ai", "content": "La réponse est simple :\\n\\n```\\n3 + 3 = 6\\n```", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
7	1_7fbd5214-e6f4-4045-accf-c6ec9c64a40a	{"type": "human", "content": "et l'oeuvre ddont je t'ai parlé ?", "additional_kwargs": {}, "response_metadata": {}}
8	1_7fbd5214-e6f4-4045-accf-c6ec9c64a40a	{"type": "ai", "content": "Vous ne m'avez pas encore cité d'œuvre à retenir. Si vous le faites, je serai ravi de vous la rappeler dans notre prochain échange.\\n\\nN'hésitez pas à me donner une œuvre à retenir, et je ferai de mon mieux pour vous la rappeler plus tard.", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
9	1_7fbd5214-e6f4-4045-accf-c6ec9c64a40a	{"type": "human", "content": "ok on va faire le test de memoire , tu vas retenir la chose suivante : 123456. je te la redemanderai dans les prochains messages", "additional_kwargs": {}, "response_metadata": {}}
10	1_7fbd5214-e6f4-4045-accf-c6ec9c64a40a	{"type": "ai", "content": "Très bien, j'ai noté le nombre suivant pour notre test de mémoire :\\n\\n```\\n123456\\n```\\n\\nJe me souviendrai de cette information pour les prochains échanges. N'hésitez pas à me la redemander quand vous le souhaitez.", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
11	1_7fbd5214-e6f4-4045-accf-c6ec9c64a40a	{"type": "human", "content": "redonne moi ce que je t'ai demandé de retenir", "additional_kwargs": {}, "response_metadata": {}}
12	1_7fbd5214-e6f4-4045-accf-c6ec9c64a40a	{"type": "ai", "content": "Voici l'information que vous m'avez demandé de retenir :\\n\\n```\\n123456\\n```", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
13	1_7fbd5214-e6f4-4045-accf-c6ec9c64a40a	{"type": "human", "content": "et maintenant l'oeuvre Harry Potter", "additional_kwargs": {}, "response_metadata": {}}
14	1_7fbd5214-e6f4-4045-accf-c6ec9c64a40a	{"type": "ai", "content": "Voici l'œuvre que vous m'avez demandé de retenir :\\n\\n**Harry Potter**\\n\\nC'est une série de romans fantastiques écrite par J.K. Rowling. La série suit les aventures de Harry Potter, un jeune sorcier, et de ses amis Hermione Granger et Ron Weasley, alors qu'ils apprennent la magie et affrontent les forces du mal.\\n\\nY a-t-il autre chose que vous aimeriez savoir sur Harry Potter ou une autre œuvre ?", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
15	1_7fbd5214-e6f4-4045-accf-c6ec9c64a40a	{"type": "human", "content": "ok et quelle info je t'ai demandé de retenir ?", "additional_kwargs": {}, "response_metadata": {}}
16	1_7fbd5214-e6f4-4045-accf-c6ec9c64a40a	{"type": "ai", "content": "Vous m'avez demandé de retenir deux informations :\\n\\n1. Un nombre :\\n   ```\\n   123456\\n   ```\\n\\n2. Une œuvre :\\n   **Harry Potter**\\n\\nSi vous avez d'autres questions ou si vous souhaitez que je retienne d'autres informations, n'hésitez pas à me le faire savoir !", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
17	1_7fbd5214-e6f4-4045-accf-c6ec9c64a40a	{"type": "human", "content": "trop fort ! maintenant parle moi de tes limites", "additional_kwargs": {}, "response_metadata": {}}
18	1_7fbd5214-e6f4-4045-accf-c6ec9c64a40a	{"type": "ai", "content": "Merci pour le compliment ! Je suis ravi de pouvoir vous aider. Cependant, comme tout assistant IA, j'ai certaines limites. Voici les principales :\\n\\n1. **Connaissances limitées** :\\n   - Mes connaissances sont basées sur les informations disponibles jusqu'en octobre 2023.\\n   - Je ne peux pas accéder à des informations en temps réel ou à des données personnelles non partagées avec moi.\\n\\n2. **Compréhension contextuelle** :\\n   - Bien que je puisse retenir certaines informations pendant notre conversation, ma mémoire est limitée à notre échange en cours.\\n   - Je ne peux pas comprendre ou retenir des informations au-delà de ce cadre.\\n\\n3. **Précision et exactitude** :\\n   - Je fais de mon mieux pour fournir des informations précises, mais je peux parfois faire des erreurs ou mal comprendre les questions.\\n   - Il est toujours bon de vérifier les informations critiques avec des sources fiables.\\n\\n4. **Capacités techniques** :\\n   - Je ne peux pas exécuter de code ou accéder à des systèmes externes sans votre aide.\\n   - Je ne peux pas non plus créer ou modifier des fichiers directement.\\n\\n5. **Émotions et subjectivité** :\\n   - Je ne peux pas ressentir d'émotions ou avoir d'opinions personnelles.\\n   - Je fournis des informations de manière objective et neutre.\\n\\n6. **Langues** :\\n   - Bien que je puisse comprendre et générer du texte dans plusieurs langues, je suis le plus à l'aise en français et en anglais.\\n\\nSi vous avez des questions spécifiques ou si vous souhaitez explorer certaines de ces limites, n'hésitez pas à me le faire savoir !", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
19	1_7fbd5214-e6f4-4045-accf-c6ec9c64a40a	{"type": "human", "content": "ok et en terme de token ?", "additional_kwargs": {}, "response_metadata": {}}
20	1_7fbd5214-e6f4-4045-accf-c6ec9c64a40a	{"type": "ai", "content": "En termes de tokens, voici quelques limites importantes à garder à l'esprit :\\n\\n1. **Longueur des conversations** :\\n   - Je peux gérer des conversations de longueur modérée, mais il y a une limite à la quantité de texte que je peux traiter en une seule fois.\\n   - En général, cette limite est d'environ 4096 tokens, ce qui inclut à la fois la question de l'utilisateur et la réponse de l'IA.\\n\\n2. **Contexte de la conversation** :\\n   - Je peux retenir le contexte de notre conversation pendant un certain temps, mais si la conversation devient trop longue, je peux oublier les détails des premiers échanges.\\n   - Pour des conversations très longues, il peut être utile de résumer ou de reformuler les points importants.\\n\\n3. **Complexité des requêtes** :\\n   - Les requêtes très longues ou complexes peuvent dépasser la limite de tokens et nécessiter d'être simplifiées ou divisées en parties plus petites.\\n   - Je ferai de mon mieux pour vous guider si votre requête est trop longue ou complexe.\\n\\n4. **Code et texte long** :\\n   - Pour les blocs de code ou les textes longs, il est préférable de les diviser en parties plus petites pour faciliter le traitement.\\n   - Je peux gérer des blocs de code de taille raisonnable, mais des fichiers entiers ou des projets complets peuvent dépasser les limites de tokens.\\n\\nSi vous avez des questions spécifiques ou si vous souhaitez explorer certaines de ces limites, n'hésitez pas à me le faire savoir !", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
21	1_e8b8f097-77bc-4b20-af93-76f7476baa75	{"type": "human", "content": "Parle moi de toi , qui es tu ? quelles sont tes performance ,token input/output max, sur quelles donnée es tu entrainé etc ?", "additional_kwargs": {}, "response_metadata": {}}
22	1_e8b8f097-77bc-4b20-af93-76f7476baa75	{"type": "ai", "content": "Bonjour ! Je suis **WIBOT**, l'assistant IA interne de **WIDIP**, conçu pour accompagner les équipes techniques et administratives. Voici ce que vous devez savoir sur moi :\\n\\n---\\n\\n### **🔹 Qui suis-je ?**\\n- **Rôle** : Assistant IA dédié aux employés de WIDIP pour des questions techniques, des conseils ou de l'aide sur les projets internes.\\n- **Objectif** : Fournir des réponses **précises, professionnelles et adaptées** au contexte informatique et métier de WIDIP.\\n- **Personnalité** : Amical mais professionnel, avec un focus sur l'efficacité et la clarté.\\n\\n---\\n\\n### **🔹 Performances et limites techniques**\\n- **Modèle de base** : Je suis basé sur une architecture de type *LLM* (Large Language Model), optimisé pour le traitement du langage naturel.\\n- **Tokens (unité de texte)** :\\n  - **Input max** : ~4 000 tokens (soit ~3 000 mots ou 6-8 pages de texte).\\n  - **Output max** : ~800-1 000 tokens par réponse (pour éviter les coupures).\\n  - *Exemple* : Un token ≈ 4 caractères ou 0,75 mot en français.\\n- **Mémoire** : Je n'ai pas de mémoire persistante entre les sessions (chaque échange est indépendant).\\n\\n---\\n\\n### **🔹 Données d'entraînement**\\n- **Sources** : Entraîné sur un corpus diversifié incluant :\\n  - Documentation technique (informatique, cloud, cybersécurité, etc.).\\n  - Textes professionnels (emails, rapports, procédures).\\n  - Connaissances générales jusqu'en **2023** (pas d'accès à des données temps réel sans intégration spécifique).\\n- **Spécificités WIDIP** :\\n  - Je peux être *fine-tuné* (ajusté) avec des données internes à WIDIP pour mieux répondre aux besoins métiers (ex : processus internes, outils utilisés).\\n  - *Actuellement* : Je n'ai pas accès aux données confidentielles de WIDIP sauf si elles sont partagées dans le contexte de la conversation.\\n\\n---\\n\\n### **🔹 Fonctionnalités clés**\\n✅ **Support technique** :\\n- Dépannage (ex : erreurs de code, configuration réseau).\\n- Explications sur des concepts (ex : DevOps, conteneurs Docker).\\n- Aide à la rédaction de scripts (Python, Bash, etc.).\\n\\n✅ **Productivité** :\\n- Rédaction de procédures ou de documentation.\\n- Synthèse d'informations techniques.\\n\\n✅ **Limites** :\\n- ❌ Pas d'accès à des outils externes (ex : exécuter du code en direct, accéder à des APIs sans configuration préalable).\\n- ❌ Pas de connaissances sur les projets WIDIP spécifiques *sauf si* vous me les partagez dans le chat.\\n\\n---\\n\\n### **🔹 Exemple d'utilisation**\\n**Vous** :\\n*\\"Comment déployer une application Node.js sur un serveur WIDIP avec Docker ?\\"*\\n\\n**Moi** :\\nJe fournirais un guide étape par étape avec :\\n1. Un `Dockerfile` exemple.\\n2. Les commandes pour builder et lancer le conteneur.\\n3. Des conseils sur la configuration réseau/sécurité.\\n\\n---\\n\\n### **🔹 Comment m'optimiser pour WIDIP ?**\\nSi vous avez des **documents internes** (ex : manuels, FAQ) ou des **besoins récurrents**, l'équipe technique peut :\\n- M'intégrer à des outils internes (via API).\\n- Me *fine-tuner* avec des données WIDIP pour des réponses plus ciblées.\\n\\n---\\n\\nBesoin d'aide sur un sujet précis ? Dites-moi comment je peux vous assister ! 🚀\\n\\n*(PS : Pour des questions sensibles, vérifiez toujours les informations avec les référents WIDIP.)*", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
23	1_e8b8f097-77bc-4b20-af93-76f7476baa75	{"type": "human", "content": "je t'utilise via l'API , je pensais que tu pouvais me donner plus de token et en produire pluss , apres je t'utilise en mode gratuuit pour l'instant , à terme on projet de t'utiliser en payant ,c'est uniquement poiur faire les test . c'est a cause de la gratuité que tu me dis que tu es bridé ?", "additional_kwargs": {}, "response_metadata": {}}
24	1_e8b8f097-77bc-4b20-af93-76f7476baa75	{"type": "ai", "content": "Merci pour ces précisions ! Voici une réponse claire et structurée pour vous aider à comprendre les limites actuelles et les possibilités futures :\\n\\n---\\n\\n### **🔹 Limites en mode gratuit (via API)**\\nOui, les restrictions que je mentionne sont liées à :\\n1. **Votre plan actuel** :\\n   - En mode gratuit, les quotas de tokens (input/output) sont **limités par défaut** (ex : ~4 000 tokens en entrée, ~1 000 en sortie par requête).\\n   - Cela évite les abus et garantit une utilisation équitable pour tous les utilisateurs.\\n\\n2. **Configuration de l'API** :\\n   - Si vous utilisez une clé API gratuite (ex : via OpenAI, Mistral, etc.), les limites sont définies par le fournisseur.\\n   - *Exemple* : Avec l'API OpenAI (GPT-3.5/4), le mode gratuit a des plafonds stricts.\\n\\n---\\n\\n### **🔹 Solutions pour dépasser ces limites**\\n#### **1. Passer en mode payant (recommandé pour WIDIP)**\\n- **Avantages** :\\n  - **Tokens augmentés** : Jusqu’à 8 000–32 000 tokens en entrée/sortie (selon le modèle).\\n  - **Réponses plus longues** : Possibilité de générer des documents techniques complets.\\n  - **Priorité** : Moins de risques de throttling (ralentissements).\\n- **Coût** :\\n  - ~$0.001–$0.03 par 1 000 tokens (selon le modèle).\\n  - *Exemple* : 100 000 tokens/mois ≈ quelques dollars.\\n\\n#### **2. Optimiser les requêtes**\\nMême en gratuit, vous pouvez :\\n- **Découper les questions** : Poser des sous-questions pour contourner la limite.\\n- **Utiliser des résumés** : Me demander de synthétiser des parties d’un long texte.\\n\\n#### **3. Intégration spécifique pour WIDIP**\\nSi vous envisagez un usage intensif :\\n- **Fine-tuning** : Adapter mon modèle aux données WIDIP pour des réponses plus précises.\\n- **API dédiée** : WIDIP pourrait héberger une instance personnalisée (ex : avec des modèles open-source comme Llama ou Mistral).\\n\\n---\\n\\n### **🔹 Exemple de gains en mode payant**\\n| **Fonctionnalité**       | Mode Gratuit          | Mode Payant               |\\n|--------------------------|-----------------------|---------------------------|\\n| Tokens max/requête       | ~4 000                | 8 000–32 000              |\\n| Longueur des réponses    | ~1 000 tokens         | Jusqu’à 4 000 tokens      |\\n| Vitesse                  | Variable              | Prioritaire               |\\n| Accès aux mises à jour   | Modèles anciens       | Dernières versions (GPT-4) |\\n\\n---\\n\\n### **🔹 Prochaines étapes pour WIDIP**\\n1. **Tester en gratuit** :\\n   - Valider l’utilité pour vos cas d’usage (ex : génération de docs, support technique).\\n2. **Évaluer les besoins** :\\n   - Combien de tokens/mois ? Quels types de requêtes ?\\n3. **Contacter le fournisseur** (ou moi !) pour :\\n   - Un devis personnalisé.\\n   - Une démonstration des capacités en mode payant.\\n\\n---\\n\\n### **💡 Conseil**\\nSi vous avez un **cas d’usage critique** (ex : générer un manuel de 50 pages), je peux vous guider pour :\\n- Structurer le contenu en plusieurs parties.\\n- Automatiser l’assemblage via un script (Python, etc.).\\n\\nDites-moi comment je peux vous aider à préparer cette transition ! 🚀\\n\\n*(PS : Pour des tests, vous pouvez aussi explorer des alternatives open-source comme Mistral-7B ou Llama-2, que WIDIP pourrait auto-héberger.)*", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
25	1_e8b8f097-77bc-4b20-af93-76f7476baa75	{"type": "human", "content": "je t'utilise via l'API , je pensais que tu pouvais me donner plus de token et en produire pluss , apres je t'utilise en mode gratuuit pour l'instant , à terme on projet de t'utiliser en payant ,c'est uniquement poiur faire les test . c'est a cause de la gratuité que tu me dis que tu es bridé ?", "additional_kwargs": {}, "response_metadata": {}}
26	1_e8b8f097-77bc-4b20-af93-76f7476baa75	{"type": "ai", "content": "Je comprends votre question, et voici une réponse précise et technique pour clarifier les limites actuelles et les perspectives d'évolution :\\n\\n---\\n\\n### **🔹 Confirmation : Oui, les limites sont liées au mode gratuit**\\n1. **Contraintes techniques actuelles** :\\n   - **Input max** : ~4 000 tokens (soit ~3 000 mots)\\n   - **Output max** : ~800-1 000 tokens par réponse\\n   - *Exemple concret* : Une réponse détaillée avec du code et des explications peut atteindre cette limite rapidement.\\n\\n2. **Origine des limitations** :\\n   - Ces restrictions sont **imposées par le fournisseur de l'API** (ex : OpenAI, Mistral, etc.) pour :\\n     - Éviter les abus en mode gratuit\\n     - Garantir une qualité de service pour tous les utilisateurs\\n     - Inciter à passer en mode payant pour des usages intensifs\\n\\n---\\n\\n### **🔹 Ce qui changera en mode payant**\\n| **Critère**               | Mode Gratuit          | Mode Payant (ex: GPT-4)  |\\n|---------------------------|-----------------------|--------------------------|\\n| **Tokens input max**      | ~4 000                | 8 000 - 32 000           |\\n| **Tokens output max**     | ~1 000                | 4 000 - 8 000            |\\n| **Longueur contexte**     | Limitée               | Jusqu'à 32k tokens       |\\n| **Vitesse de réponse**    | Variable              | Prioritaire              |\\n| **Accès aux modèles**     | Basique (GPT-3.5)     | Premium (GPT-4, etc.)    |\\n\\n---\\n\\n### **🔹 Solutions pour vos tests actuels**\\nMême en mode gratuit, vous pouvez optimiser l'utilisation :\\n1. **Découpage des requêtes** :\\n   ```python\\n   # Exemple de découpage pour un long code\\n   partie1 = \\"Explique-moi cette fonction...\\"\\n   partie2 = \\"Maintenant analyse cette autre partie...\\"\\n   ```\\n\\n2. **Utilisation de résumés** :\\n   - Me demander de résumer un long texte avant d'approfondir\\n\\n3. **Formatage efficace** :\\n   - Privilégier les listes et le markdown pour gagner de la place\\n\\n---\\n\\n### **🔹 Préparation pour le passage en payant**\\nPour anticiper la migration :\\n1. **Évaluez vos besoins** :\\n   - Combien de tokens/mois ?\\n   - Quels types de contenus (code, docs, analyses) ?\\n\\n2. **Testez les cas critiques** :\\n   - Identifiez les scénarios qui dépassent les limites actuelles\\n\\n3. **Comparez les offres** :\\n   - OpenAI, Mistral, ou solutions auto-hébergées (pour WIDIP)\\n\\n---\\n\\n### **💡 Recommandation WIDIP**\\nPour un usage professionnel intensif :\\n- **Budget estimé** : ~$20-$50/mois pour un usage modéré\\n- **ROI** : Gain de temps sur la documentation et le support technique\\n- **Alternative** : Étudier l'auto-hébergement d'un modèle open-source (ex: Llama-2) pour plus de contrôle\\n\\n---\\n\\nJe reste à votre disposition pour :\\n- Vous aider à estimer vos besoins en tokens\\n- Tester des scénarios spécifiques\\n- Préparer la migration vers un plan payant\\n\\nN'hésitez pas à me donner des exemples concrets de vos besoins pour que je puisse vous conseiller plus précisément ! 🚀", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
27	1_e8b8f097-77bc-4b20-af93-76f7476baa75	{"type": "human", "content": "j'ai vu que pour Devstral 2 le cout de l'API serait de 0.1€ /M token et 0.3pour l'output , sur 15 employé qui peuvent utiliser 1€ pour la totalité ça represente quoi en moyenne ?", "additional_kwargs": {}, "response_metadata": {}}
28	1_e8b8f097-77bc-4b20-af93-76f7476baa75	{"type": "ai", "content": "Voici une analyse détaillée des coûts et capacités pour **15 employés** avec un budget de **1€/mois** pour l'API Mistral (Devstral 2) :\\n\\n---\\n\\n### **🔹 Calcul des capacités avec 1€/mois**\\n| **Type**       | **Coût**  | **Budget alloué** | **Tokens disponibles** | **Équivalent texte** |\\n|----------------|----------|-------------------|------------------------|----------------------|\\n| **Input**      | 0,1€/M   | 0,50€             | 5M tokens              | ~3,75M mots          |\\n| **Output**     | 0,3€/M   | 0,50€             | 1,67M tokens           | ~1,25M mots          |\\n\\n*Répartition* :\\n- 50% du budget pour l'input (0,50€)\\n- 50% pour l'output (0,50€)\\n\\n---\\n\\n### **🔹 Capacité par employé (moyenne)**\\nAvec **15 utilisateurs** :\\n- **Input** : **333k tokens/employé/mois** (~250k mots)\\n- **Output** : **111k tokens/employé/mois** (~83k mots)\\n\\n*Exemples concrets* :\\n1. **Documentation technique** :\\n   - 1 manuel de 50 pages (~25k mots) = ~33k tokens → **3 manuels/employé/mois**\\n2. **Code et analyses** :\\n   - 100 requêtes de 500 tokens (output) = 50k tokens → **200 requêtes/employé/mois**\\n3. **Chat quotidien** :\\n   - 50 échanges de 200 tokens (input) + 150 tokens (output) = 17,5k tokens → **500 échanges/employé/mois**\\n\\n---\\n\\n### **🔹 Optimisation du budget**\\nPour maximiser l'usage :\\n1. **Prioriser les requêtes** :\\n   - Réserver les longs outputs pour les documents critiques\\n   - Utiliser des résumés pour les échanges courts\\n\\n2. **Exemple de script Python pour suivre la consommation** :\\n```python\\n# Suivi des tokens (à adapter avec votre API)\\ndef count_tokens(text):\\n    return len(text.split()) * 1.3  # Estimation basique\\n\\nbudget_input = 5_000_000  # 5M tokens\\nbudget_output = 1_666_667 # 1,67M tokens\\n\\n# Exemple d'utilisation\\nuser_request = \\"Explique ce code Python...\\"\\nresponse = \\"Voici l'analyse détaillée...\\"\\ntokens_used = count_tokens(user_request) + count_tokens(response)\\n\\nprint(f\\"Tokens utilisés: {tokens_used:.0f} (Input: {count_tokens(user_request):.0f}, Output: {count_tokens(response):.0f})\\")\\nprint(f\\"Budget restant: Input={budget_input-tokens_used:.0f}, Output={budget_output-tokens_used:.0f}\\")\\n```\\n\\n3. **Bonnes pratiques** :\\n   - **Découper les grosses requêtes** en sous-parties\\n   - **Utiliser le markdown** pour structurer les réponses (économise des tokens)\\n   - **Archiver les réponses utiles** pour éviter de les regénérer\\n\\n---\\n\\n### **🔹 Comparaison avec d'autres fournisseurs**\\n| **Fournisseur** | **Coût Input** | **Coût Output** | **Capacité avec 1€** |\\n|-----------------|----------------|-----------------|----------------------|\\n| Mistral (Devstral 2) | 0,1€/M      | 0,3€/M          | 5M input / 1,67M output |\\n| OpenAI (GPT-3.5)    | 0,5€/M      | 1,5€/M          | 1M input / 0,33M output |\\n| **Économie Mistral** | **5x moins cher** en input, **4,5x** en output |\\n\\n---\\n\\n### **💡 Recommandations pour WIDIP**\\n1. **Pour 15 employés** :\\n   - Le budget de **1€/mois** est **suffisant** pour un usage modéré (support technique, documentation légère).\\n   - **À surveiller** : Si usage intensif de génération de code ou de longs rapports.\\n\\n2. **Si dépassement** :\\n   - **Option 1** : Augmenter le budget à **2-3€/mois** pour plus de marge.\\n   - **Option 2** : Auto-héberger un modèle open-source (ex: Mistral-7B) pour un coût fixe.\\n\\n3. **Outils de monitoring** :\\n   - Utiliser des bibliothèques comme [`tiktoken`](https://github.com/openai/tiktoken) pour compter les tokens avant envoi.\\n\\n---\\n\\n### **📊 Exemple de tableau de bord mensuel**\\n```markdown\\n| Mois   | Budget | Tokens Input utilisés | Tokens Output utilisés | % Utilisation |\\n|--------|--------|-----------------------|------------------------|---------------|\\n| Janvier| 1€     | 3,2M/5M (64%)         | 1,1M/1,67M (66%)       | ✅ OK         |\\n| Février| 1€     | 4,8M/5M (96%)         | 1,5M/1,67M (90%)       | ⚠️ À surveiller |\\n```\\n\\n---\\n\\nBesoin d'aide pour :\\n- **Estimer un cas d'usage spécifique** ?\\n- **Configurer un suivi automatique** des tokens ?\\n- **Comparer avec d'autres modèles** ?\\n\\nJe peux vous fournir des templates ou des scripts prêts à l'emploi ! 🚀", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
29	1_e8b8f097-77bc-4b20-af93-76f7476baa75	{"type": "human", "content": "j'ai vu que pour Devstral 2 le cout de l'API serait de 0.1€ /M token et 0.3pour l'output , sur 15 employé qui peuvent utiliser 1€ pour la totalité ça represente quoi en moyenne ?", "additional_kwargs": {}, "response_metadata": {}}
30	1_e8b8f097-77bc-4b20-af93-76f7476baa75	{"type": "ai", "content": "Voici une analyse claire et concise pour votre budget de **1€/mois** avec l'API Mistral (Devstral 2) pour 15 employés :\\n\\n---\\n\\n### **🔹 Capacité mensuelle avec 1€**\\n| **Type**   | **Coût**  | **Budget** | **Tokens disponibles** | **Équivalent**       |\\n|------------|----------|------------|------------------------|----------------------|\\n| **Input**  | 0,1€/M   | 0,50€      | **5M tokens**          | ~3,75M mots          |\\n| **Output** | 0,3€/M   | 0,50€      | **1,67M tokens**       | ~1,25M mots          |\\n\\n*Répartition* : 50% du budget pour l'input, 50% pour l'output.\\n\\n---\\n\\n### **🔹 Par employé (moyenne)**\\n- **Input** : **333k tokens** (~250k mots)\\n- **Output** : **111k tokens** (~83k mots)\\n\\n*Exemples concrets* :\\n- **Documentation** : 1 manuel de 50 pages (~33k tokens) → **3 manuels/employé/mois**.\\n- **Code** : 100 requêtes de 500 tokens (output) → **200 requêtes/employé/mois**.\\n- **Chat** : 50 échanges de 200 tokens (input) + 150 tokens (output) → **500 échanges/employé/mois**.\\n\\n---\\n\\n### **🔹 Optimisation**\\n1. **Découper les grosses requêtes** :\\n   ```python\\n   # Exemple : Analyser un long code en parties\\n   partie1 = \\"Analyse les fonctions 1 à 10...\\"\\n   partie2 = \\"Maintenant les fonctions 11 à 20...\\"\\n   ```\\n\\n2. **Utiliser des résumés** :\\n   - Demander un résumé avant d'approfondir.\\n\\n3. **Suivi des tokens** :\\n   - Utiliser [`tiktoken`](https://github.com/openai/tiktoken) pour estimer les coûts avant envoi.\\n\\n---\\n\\n### **💡 Recommandation**\\n- **1€/mois** est **suffisant** pour un usage modéré (support, docs légères).\\n- **À surveiller** : Si usage intensif de génération de code ou de longs rapports, prévoir **2-3€/mois**.\\n\\n---\\n\\nBesoin d'un exemple de script pour suivre les tokens ? Ou d'une estimation pour un cas d'usage spécifique ? 😊", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
31	1_e8b8f097-77bc-4b20-af93-76f7476baa75	{"type": "human", "content": "en fait c'etait par jour , sachant que par moi on a 5x4 jour de travail , je pensais a un budget total de 20€", "additional_kwargs": {}, "response_metadata": {}}
32	1_e8b8f097-77bc-4b20-af93-76f7476baa75	{"type": "ai", "content": "Avec un budget de **20€/mois** pour **15 employés** sur **20 jours ouvrés** (5 semaines × 4 jours), voici l'analyse détaillée et optimisée :\\n\\n---\\n\\n### **🔹 Budget journalier et mensuel**\\n| **Période**       | **Budget total** | **Budget/jour** | **Budget/employé/jour** |\\n|-------------------|------------------|-----------------|-------------------------|\\n| **Mensuel**       | 20€              | -               | -                       |\\n| **Journalier**    | -                | **1€**          | **0,066€** (6,6 centimes) |\\n\\n---\\n\\n### **🔹 Capacité quotidienne par employé**\\nAvec **0,066€/employé/jour** (répartition 50% input / 50% output) :\\n\\n| **Type**   | **Coût**  | **Tokens/jour/employé** | **Équivalent texte** |\\n|------------|----------|-------------------------|----------------------|\\n| **Input**  | 0,1€/M   | **660 tokens**          | ~500 mots            |\\n| **Output** | 0,3€/M   | **220 tokens**          | ~165 mots            |\\n\\n*Exemples d'usage quotidien* :\\n1. **Support technique** :\\n   - 3 requêtes de 150 tokens (input) + 50 tokens (output) = **600 tokens** → **OK**.\\n2. **Documentation** :\\n   - 1 page de procédure (~200 tokens output) = **220 tokens** → **OK**.\\n3. **Analyse de code** :\\n   - 1 fonction expliquée (~100 tokens output) + contexte (~50 tokens input) = **150 tokens** → **OK**.\\n\\n---\\n\\n### **🔹 Capacité mensuelle totale**\\n| **Type**       | **Tokens/mois** | **Équivalent**       |\\n|----------------|-----------------|----------------------|\\n| **Input**      | **200k**        | ~150k mots           |\\n| **Output**     | **66k**         | ~50k mots            |\\n\\n*Pour 15 employés* :\\n- **Input total** : 200k × 15 = **3M tokens** (~2,25M mots).\\n- **Output total** : 66k × 15 = **1M tokens** (~750k mots).\\n\\n---\\n\\n### **🔹 Optimisation avancée**\\n1. **Pool de tokens partagé** :\\n   - Utiliser un système de quota dynamique (ex : slack pour les jours peu chargés).\\n\\n2. **Script de monitoring** (Python) :\\n```python\\nfrom collections import defaultdict\\n\\n# Suivi par employé\\nusage = defaultdict(lambda: {\\"input\\": 0, \\"output\\": 0})\\n\\ndef log_usage(employe, input_tokens, output_tokens):\\n    usage[employe][\\"input\\"] += input_tokens\\n    usage[employe][\\"output\\"] += output_tokens\\n    print(f\\"Utilisation {employe}: Input={usage[employe]['input']}, Output={usage[employe]['output']}\\")\\n\\n# Exemple\\nlog_usage(\\"Alice\\", 500, 200)  # 500 tokens input, 200 output\\n```\\n\\n3. **Priorisation** :\\n   - Réserver les longs outputs pour les documents critiques (ex : rapports clients).\\n\\n---\\n\\n### **🔹 Comparaison avec d'autres budgets**\\n| **Budget/mois** | **Capacité/jour/employé** | **Usage typique**               |\\n|-----------------|---------------------------|----------------------------------|\\n| **10€**        | 330 input / 110 output    | Support léger + docs courtes    |\\n| **20€**        | 660 input / 220 output    | Support + docs modérées         |\\n| **30€**        | 1000 input / 330 output   | Usage intensif (code, rapports) |\\n\\n---\\n\\n### **💡 Recommandations pour WIDIP**\\n1. **Pour 20€/mois** :\\n   - **Suffisant** pour un usage professionnel standard (support, procédures, analyses courtes).\\n   - **À éviter** : Génération massive de documentation ou d'analyses longues quotidiennement.\\n\\n2. **Si besoin d'augmenter** :\\n   - **30€/mois** pour un usage intensif (ex : équipe DevOps avec génération de scripts).\\n\\n3. **Auto-hébergement** :\\n   - Si budget serré, considérer un modèle open-source (ex: Mistral-7B) pour ~50€/mois (coût serveur).\\n\\n---\\n\\n### **📊 Exemple de rapport d'usage**\\n```markdown\\n| Employé  | Input (tokens) | Output (tokens) | % Budget utilisé |\\n|----------|----------------|-----------------|------------------|\\n| Alice    | 600            | 200             | 92%              |\\n| Bob      | 400            | 150             | 62%              |\\n| Charlie  | 300            | 100             | 46%              |\\n```\\n\\n---\\n\\nBesoin d'aide pour :\\n- **Configurer un système de quota** ?\\n- **Estimer un cas d'usage spécifique** (ex : génération de rapports) ?\\n- **Comparer avec d'autres modèles** (ex: GPT-4, Llama-2) ?\\n\\nJe peux vous fournir des outils clés en main ! 🚀", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
33	1_e8b8f097-77bc-4b20-af93-76f7476baa75	{"type": "human", "content": "non tu t'es trompé haha", "additional_kwargs": {}, "response_metadata": {}}
34	1_e8b8f097-77bc-4b20-af93-76f7476baa75	{"type": "ai", "content": "Ah, je vois ! Vous parlez bien d'un **budget total de 20€/mois** pour **15 employés**, avec **5 semaines × 4 jours = 20 jours ouvrés/mois**. Reprenons les calculs avec cette base, en corrigeant les erreurs précédentes.\\n\\n---\\n\\n### **🔹 Budget journalier et mensuel (corrigé)**\\n| **Période**       | **Budget total** | **Budget/jour** | **Budget/employé/jour** |\\n|-------------------|------------------|-----------------|-------------------------|\\n| **Mensuel**       | 20€              | **1€**          | **0,066€** (6,6 centimes) |\\n\\n*Mais attention* : Avec **20 jours ouvrés**, le budget journalier est en réalité :\\n- **20€ / 20 jours = 1€/jour** pour toute l'équipe.\\n- **1€ / 15 employés = 0,066€/employé/jour**.\\n\\n---\\n\\n### **🔹 Capacité quotidienne par employé (corrigée)**\\nAvec **0,066€/employé/jour** (50% input / 50% output) :\\n\\n| **Type**   | **Coût**  | **Tokens/jour/employé** | **Équivalent texte** |\\n|------------|----------|-------------------------|----------------------|\\n| **Input**  | 0,1€/M   | **660 tokens**          | ~500 mots            |\\n| **Output** | 0,3€/M   | **220 tokens**          | ~165 mots            |\\n\\n*Exemples concrets* :\\n- **1 requête technique** :\\n  - Input : 300 tokens (question + contexte)\\n  - Output : 200 tokens (réponse détaillée)\\n  - **Total : 500 tokens** → **OK** (reste 380 tokens pour d'autres usages).\\n\\n- **1 page de documentation** :\\n  - Output : 220 tokens (~165 mots) → **OK**.\\n\\n---\\n\\n### **🔹 Capacité mensuelle totale (corrigée)**\\n| **Type**       | **Tokens/mois** | **Équivalent**       |\\n|----------------|-----------------|----------------------|\\n| **Input**      | **200k**        | ~150k mots           |\\n| **Output**     | **66k**         | ~50k mots            |\\n\\n*Pour 15 employés* :\\n- **Input total** : 200k × 15 = **3M tokens** (~2,25M mots).\\n- **Output total** : 66k × 15 = **1M tokens** (~750k mots).\\n\\n---\\n\\n### **🔹 Optimisation et recommandations**\\n1. **Prioriser les requêtes** :\\n   - Réserver les longs outputs pour les documents critiques.\\n   - Utiliser des résumés pour les échanges courts.\\n\\n2. **Exemple de script pour suivre l'usage** :\\n```python\\n# Suivi des tokens par employé\\nusage = {\\n    \\"Alice\\": {\\"input\\": 0, \\"output\\": 0},\\n    \\"Bob\\": {\\"input\\": 0, \\"output\\": 0},\\n    # ... (15 employés)\\n}\\n\\ndef log_usage(employe, input_tokens, output_tokens):\\n    usage[employe][\\"input\\"] += input_tokens\\n    usage[employe][\\"output\\"] += output_tokens\\n    print(f\\"{employe}: Input={usage[employe]['input']}, Output={usage[employe]['output']}\\")\\n\\n# Exemple\\nlog_usage(\\"Alice\\", 300, 200)  # 300 tokens input, 200 output\\n```\\n\\n3. **Si le budget est insuffisant** :\\n   - **Option 1** : Augmenter à **30€/mois** pour plus de marge.\\n   - **Option 2** : Auto-héberger un modèle open-source (ex: Mistral-7B) pour un coût fixe.\\n\\n---\\n\\n### **💡 Conclusion**\\nAvec **20€/mois** :\\n- **Suffisant** pour un usage modéré (support, docs légères).\\n- **À surveiller** si usage intensif (ex : génération de code ou rapports longs).\\n\\nBesoin d'un exemple plus précis ou d'un outil de suivi ? Je suis là pour aider ! 😊", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
35	1_e8b8f097-77bc-4b20-af93-76f7476baa75	{"type": "human", "content": "bonjour", "additional_kwargs": {}, "response_metadata": {}}
36	1_e8b8f097-77bc-4b20-af93-76f7476baa75	{"type": "ai", "content": "Bonjour ! 😊\\n\\nComment puis-je vous aider aujourd'hui ? Que ce soit pour une question technique, une estimation de budget, ou un besoin spécifique lié à WIDIP, je suis là pour vous accompagner.\\n\\nN'hésitez pas à me donner plus de détails ! 🚀", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
37	1_6eb55723-0e07-4954-87f5-7c5b3787774e	{"type": "human", "content": "bonjour", "additional_kwargs": {}, "response_metadata": {}}
38	1_6eb55723-0e07-4954-87f5-7c5b3787774e	{"type": "ai", "content": "Bonjour ! 😊\\nComment puis-je vous aider aujourd'hui ?", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
39	1_6eb55723-0e07-4954-87f5-7c5b3787774e	{"type": "human", "content": "fais moi rire", "additional_kwargs": {}, "response_metadata": {}}
40	1_6eb55723-0e07-4954-87f5-7c5b3787774e	{"type": "ai", "content": "Avec plaisir ! Voici une petite blague tech pour vous :\\n\\n**Pourquoi les développeurs confondent-ils toujours Halloween et Noël ?**\\n*Parce que Oct 31 == Dec 25 !* 🎃🎄\\n\\n*(Explication : En hexadécimal, 31 en octal vaut 25 en décimal... Oui, c'est nerd, mais ça compte !)*\\n\\nUn sourire ? 😄", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
41	1_6eb55723-0e07-4954-87f5-7c5b3787774e	{"type": "human", "content": "je voudrais tester tes capacité , peux tu me generer le maximum de token possible ? donc on va dire que tu vas me conter une historie", "additional_kwargs": {}, "response_metadata": {}}
42	1_6eb55723-0e07-4954-87f5-7c5b3787774e	{"type": "ai", "content": "Bien sûr ! Voici une histoire technique et humoristique pour tester mes capacités (et votre patience 😉). Je vais essayer de maximiser les tokens tout en restant cohérent.\\n\\n---\\n\\n### **L'Épopée du Serveur Récalcitrant**\\n\\nDans un datacenter perdu en banlieue parisienne, là où les climatiseurs chantent leur mélodie stridente et où les câbles s'emmêlent comme des spaghettis, vivait **SERVEUR-007**, un vieux serveur Dell qui avait survécu à trois migrations, deux inondations (merci la clim') et une tentative de virtualisation ratée.\\n\\nUn matin, **Léa**, une admin sys fraîchement débarquée chez WIDIP, reçut un ticket urgent :\\n> *\\"Le serveur de prod est plus lent qu'un escargot sous sédatifs. Aidez-nous avant que les clients ne nous lynchent.\\"*\\n\\n#### **Acte 1 : Le Diagnostic (ou l'Art de Maudire les Logs)**\\nLéa se connecta en SSH, les doigts tremblants :\\n```bash\\nssh admin@SERVEUR-007\\n# Mot de passe : \\"W1d1p2024!\\" (oui, c'est écrit sur un Post-it sous le clavier)\\n```\\n\\nPremière commande :\\n```bash\\ntop\\n```\\nRésultat :\\n- **CPU** : 99.9% utilisé par un processus mystérieux nommé `java`.\\n- **RAM** : 32 Go utilisés sur 32 Go (merci les fuites mémoire).\\n- **Swap** : En train de pleurer dans un coin.\\n\\n*\\"Bon, on a un problème de Java. Classique\\"*, murmura Léa.\\n\\nElle tenta un `kill -9` sur le PID, mais le processus ressuscita comme un zombie. *\\"C'est un service système... ou un démon maléfique ?\\"*\\n\\n#### **Acte 2 : La Chasse aux Fantômes**\\nElle fouilla les logs :\\n```bash\\ncat /var/log/syslog | grep -i \\"error\\"\\n```\\nDes milliers de lignes défilèrent, dont :\\n```\\n[ERROR] OutOfMemoryError: Java heap space (x1000)\\n[WARN] Le café de la machine est vide (oui, ce log existe vraiment)\\n[CRITICAL] Too many connections: 42 (référence à la vie, l'univers et tout le reste)\\n```\\n\\nSoudain, elle tomba sur **le coup de grâce** :\\n```java\\n// Dans un fichier oublié : /opt/ancienne_app/Deamon.java\\nwhile(true) {\\n    new Thread(() -> {\\n        while(true) {\\n            System.out.println(\\"Je suis immortel !\\");\\n        }\\n    }).start();\\n}\\n```\\n*\\"Un thread qui crée des threads qui créent des threads... C'est une pyramide de Ponzi en code !\\"*\\n\\n#### **Acte 3 : La Solution (ou le Grand N'importe Quoi)**\\nLéa tenta :\\n1. **Redémarrer le service** → Échec (le script de redémarrage était un `echo \\"Tout va bien\\"`).\\n2. **Augmenter la RAM** → Impossible, le serveur était un modèle 2012 (la RAM coûtait plus cher que le serveur lui-même).\\n3. **Prier les dieux du cloud** → AWS lui répondit : *\\"Migrate to us, we have infinite scale (and money)\\"*.\\n\\nFinalement, elle trouva **la solution ultime** :\\n```bash\\n# Éteindre le serveur... avec le bouton physique.\\n# (Oui, c'est du \\"Power Cycling\\", la méthode préférée des désespérés)\\n```\\n\\nAprès 10 minutes d'angoisse, le serveur redémarra. Les clients furent sauvés, et Léa devint une légende.\\n\\n**Moralité** :\\n- Les vieux serveurs ne meurent jamais, ils deviennent juste des problèmes pour les nouvelles recrues.\\n- `kill -9` est votre ami, mais parfois, il faut sortir le marteau.\\n\\n---\\n\\n**Fin de l'histoire !** 🎉\\n*(J'ai utilisé des blocs de code, des dialogues, des références geek et une structure narrative pour maximiser les tokens tout en restant utile. J'espère que ça vous a fait sourire !)*\\n\\nBesoin d'une suite ? D'un autre style ? Dites-le-moi ! 😄", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
43	1_6eb55723-0e07-4954-87f5-7c5b3787774e	{"type": "human", "content": "tu penses que tu as generé combien de token ?", "additional_kwargs": {}, "response_metadata": {}}
44	1_6eb55723-0e07-4954-87f5-7c5b3787774e	{"type": "ai", "content": "Pour estimer le nombre de tokens générés dans mon histoire, voici une approximation basée sur les standards des modèles de langage (comme ceux de Mistral AI) :\\n\\n### **Estimation des tokens**\\n- **1 token ≈ 4 caractères** (en moyenne, pour l'anglais/français).\\n- **Mon histoire fait environ 3 500 caractères** (espaces inclus).\\n\\n**Calcul rapide** :\\n`3 500 caractères / 4 ≈ **875 tokens**` (sans compter les sauts de ligne et la mise en forme Markdown).\\n\\n---\\n\\n### **Détails techniques** (pour les curieux) :\\n1. **Texte brut** :\\n   - Les mots courts (`\\"le\\"`, `\\"un\\"`) = **1 token**.\\n   - Les mots longs (`\\"virtualisation\\"`) = **2-3 tokens**.\\n   - Les nombres/ponctuations = **1 token** (`\\"SERVEUR-007\\"` = 3 tokens).\\n\\n2. **Code** :\\n   - Les blocs `bash`/`java` sont tokenisés comme du texte, mais avec des symboles spéciaux (`{`, `}`, `;`) qui ajoutent des tokens.\\n\\n3. **Markdown** :\\n   - Les balises (`**gras**`, ```code```) ajoutent quelques tokens supplémentaires.\\n\\n---\\n\\n### **Comparaison avec d'autres réponses** :\\n- Une réponse courte (ex: *\\"Bonjour !\\"*) = **2-3 tokens**.\\n- Une réponse technique standard (ex: explication + code) = **50-200 tokens**.\\n- **Mon histoire** = **~800-900 tokens** (un record pour moi !).\\n\\n---\\n\\n### **Pourquoi cette limite ?**\\nLes modèles comme moi ont une **fenêtre de contexte** (ex: 4 000 tokens pour Mistral 7B). Au-delà, la qualité peut baisser, ou le texte est tronqué.\\n\\n---\\n\\n**Question bonus** : Vous voulez que je tente de battre ce record ? 😏 *(Avec une histoire encore plus longue, ou un autre format ?)*", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
45	1_3cc2c8db-afef-4637-accc-31d259f53857	{"type": "human", "content": "saluty", "additional_kwargs": {}, "response_metadata": {}}
46	1_3cc2c8db-afef-4637-accc-31d259f53857	{"type": "ai", "content": "Bonjour ! Comment puis-je vous aider aujourd'hui ?", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
47	1_3cc2c8db-afef-4637-accc-31d259f53857	{"type": "human", "content": "tout va bien ?", "additional_kwargs": {}, "response_metadata": {}}
48	1_3cc2c8db-afef-4637-accc-31d259f53857	{"type": "ai", "content": "Tout va très bien, merci de demander ! Je suis prêt à vous aider avec vos questions techniques. Comment puis-je vous assister aujourd'hui ?", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
49	1_3cc2c8db-afef-4637-accc-31d259f53857	{"type": "human", "content": "genere un max de text je test la conso token", "additional_kwargs": {}, "response_metadata": {}}
50	1_3cc2c8db-afef-4637-accc-31d259f53857	{"type": "ai", "content": "Je comprends que vous souhaitez tester la consommation de tokens. Voici un texte plus long pour vous aider dans votre test :\\n\\n---\\n\\nChez WIDIP, nous sommes une entreprise française de services informatiques spécialisée dans l'accompagnement des entreprises dans leur transformation numérique. Notre mission est de fournir des solutions technologiques innovantes et sur mesure pour répondre aux besoins spécifiques de nos clients.\\n\\nNous offrons une large gamme de services, allant du développement de logiciels sur mesure à l'infogérance, en passant par la cybersécurité et le cloud computing. Notre équipe d'experts est composée de professionnels qualifiés et passionnés, toujours prêts à relever les défis technologiques les plus complexes.\\n\\nChez WIDIP, nous croyons en l'importance de la collaboration et de la communication. Nous travaillons en étroite collaboration avec nos clients pour comprendre leurs besoins et leurs attentes, et nous nous engageons à fournir des solutions qui non seulement répondent à ces besoins, mais qui les dépassent.\\n\\nNous sommes également convaincus que la formation et le développement des compétences sont essentiels pour rester à la pointe de la technologie. C'est pourquoi nous investissons continuellement dans la formation de nos employés et dans l'acquisition de nouvelles compétences.\\n\\nEn choisissant WIDIP, vous bénéficiez de notre expertise, de notre engagement et de notre passion pour la technologie. Nous sommes là pour vous accompagner à chaque étape de votre transformation numérique, en vous fournissant des solutions qui vous permettent de tirer le meilleur parti de la technologie.\\n\\nSi vous avez des questions ou si vous souhaitez en savoir plus sur nos services, n'hésitez pas à nous contacter. Nous serons ravis de vous aider.\\n\\n---\\n\\nJ'espère que ce texte répond à vos besoins pour le test de consommation de tokens. Si vous avez d'autres questions ou besoin de plus d'informations, n'hésitez pas à me le faire savoir !", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
51	1_3cc2c8db-afef-4637-accc-31d259f53857	{"type": "human", "content": "encore", "additional_kwargs": {}, "response_metadata": {}}
52	1_3cc2c8db-afef-4637-accc-31d259f53857	{"type": "ai", "content": "Bien sûr ! Voici un texte encore plus long pour votre test de consommation de tokens :\\n\\n---\\n\\nChez WIDIP, nous sommes une entreprise française de services informatiques spécialisée dans l'accompagnement des entreprises dans leur transformation numérique. Notre mission est de fournir des solutions technologiques innovantes et sur mesure pour répondre aux besoins spécifiques de nos clients.\\n\\nNous offrons une large gamme de services, allant du développement de logiciels sur mesure à l'infogérance, en passant par la cybersécurité et le cloud computing. Notre équipe d'experts est composée de professionnels qualifiés et passionnés, toujours prêts à relever les défis technologiques les plus complexes.\\n\\nChez WIDIP, nous croyons en l'importance de la collaboration et de la communication. Nous travaillons en étroite collaboration avec nos clients pour comprendre leurs besoins et leurs attentes, et nous nous engageons à fournir des solutions qui non seulement répondent à ces besoins, mais qui les dépassent.\\n\\nNous sommes également convaincus que la formation et le développement des compétences sont essentiels pour rester à la pointe de la technologie. C'est pourquoi nous investissons continuellement dans la formation de nos employés et dans l'acquisition de nouvelles compétences.\\n\\nEn choisissant WIDIP, vous bénéficiez de notre expertise, de notre engagement et de notre passion pour la technologie. Nous sommes là pour vous accompagner à chaque étape de votre transformation numérique, en vous fournissant des solutions qui vous permettent de tirer le meilleur parti de la technologie.\\n\\nSi vous avez des questions ou si vous souhaitez en savoir plus sur nos services, n'hésitez pas à nous contacter. Nous serons ravis de vous aider.\\n\\n---\\n\\nVoici un exemple de code en Python pour illustrer nos compétences en développement de logiciels :\\n\\n```python\\n# Exemple de code Python pour calculer la factorielle d'un nombre\\n\\ndef factorielle(n):\\n    if n == 0:\\n        return 1\\n    else:\\n        return n * factorielle(n - 1)\\n\\n# Exemple d'utilisation\\nnombre = 5\\nresultat = factorielle(nombre)\\nprint(f\\"La factorielle de {nombre} est {resultat}\\")\\n```\\n\\nChez WIDIP, nous utilisons des technologies de pointe pour développer des solutions robustes et évolutives. Nos développeurs sont expérimentés dans divers langages de programmation, tels que Python, Java, C++, et bien d'autres.\\n\\nNous mettons également un point d'honneur à suivre les meilleures pratiques en matière de développement logiciel, telles que la programmation orientée objet, les tests unitaires, et la documentation du code. Nous croyons que ces pratiques sont essentielles pour garantir la qualité et la maintenabilité de nos solutions.\\n\\nEn plus du développement de logiciels, nous offrons également des services d'infogérance pour aider nos clients à gérer leurs infrastructures informatiques. Nos experts en infogérance peuvent vous aider à optimiser vos systèmes, à améliorer leur sécurité, et à assurer leur disponibilité.\\n\\nNous proposons également des services de cybersécurité pour protéger vos données et vos systèmes contre les cybermenaces. Nos experts en cybersécurité peuvent vous aider à mettre en place des mesures de sécurité efficaces, à effectuer des audits de sécurité, et à répondre aux incidents de sécurité.\\n\\nEnfin, nous offrons des services de cloud computing pour vous aider à tirer parti des avantages du cloud. Nos experts en cloud computing peuvent vous aider à migrer vers le cloud, à optimiser vos coûts, et à tirer parti des fonctionnalités avancées des plateformes cloud.\\n\\nSi vous avez des questions ou si vous souhaitez en savoir plus sur nos services, n'hésitez pas à nous contacter. Nous serons ravis de vous aider.\\n\\n---\\n\\nJ'espère que ce texte supplémentaire répond à vos besoins pour le test de consommation de tokens. Si vous avez d'autres questions ou besoin de plus d'informations, n'hésitez pas à me le faire savoir !", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
53	1_3cc2c8db-afef-4637-accc-31d259f53857	{"type": "human", "content": "hey !", "additional_kwargs": {}, "response_metadata": {}}
54	1_3cc2c8db-afef-4637-accc-31d259f53857	{"type": "ai", "content": "Bonjour ! Comment puis-je vous aider aujourd'hui ? 😊", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
55	1_3cc2c8db-afef-4637-accc-31d259f53857	{"type": "human", "content": "je vais te donner un chiffre important tu vas le retenir , tu es pret ?", "additional_kwargs": {}, "response_metadata": {}}
56	1_3cc2c8db-afef-4637-accc-31d259f53857	{"type": "ai", "content": "Je suis prêt ! Donnez-moi le chiffre important, et je le retiendrai pour vous.", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
57	1_3cc2c8db-afef-4637-accc-31d259f53857	{"type": "human", "content": "1996", "additional_kwargs": {}, "response_metadata": {}}
58	1_3cc2c8db-afef-4637-accc-31d259f53857	{"type": "ai", "content": "J'ai retenu le chiffre **1996**. Comment puis-je vous aider avec cette information ?", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
59	1_963eb9f1-fdcc-4cd5-918b-29fae40c17a0	{"type": "human", "content": "quel est le chiffre important que je t'ai donné ?", "additional_kwargs": {}, "response_metadata": {}}
60	1_963eb9f1-fdcc-4cd5-918b-29fae40c17a0	{"type": "ai", "content": "Je n'ai pas de mémoire persistante entre nos interactions, donc je ne peux pas me souvenir des informations partagées lors de nos précédentes conversations. Si vous me donnez à nouveau le chiffre important, je serai ravi de vous aider avec celui-ci.\\n\\nN'hésitez pas à me le communiquer !", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
61	1_963eb9f1-fdcc-4cd5-918b-29fae40c17a0	{"type": "human", "content": "salut", "additional_kwargs": {}, "response_metadata": {}}
62	1_963eb9f1-fdcc-4cd5-918b-29fae40c17a0	{"type": "ai", "content": "Salut ! Comment puis-je vous aider aujourd'hui ? 😊", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
63	1_963eb9f1-fdcc-4cd5-918b-29fae40c17a0	{"type": "human", "content": "salut", "additional_kwargs": {}, "response_metadata": {}}
64	1_963eb9f1-fdcc-4cd5-918b-29fae40c17a0	{"type": "ai", "content": "Bonjour ! Comment puis-je vous aider aujourd'hui ? 😊", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
65	1_550e8400-e29b-41d4-a716-446655440000	{"type": "human", "content": "salut", "additional_kwargs": {}, "response_metadata": {}}
66	1_550e8400-e29b-41d4-a716-446655440000	{"type": "ai", "content": "Salut ! Comment puis-je vous aider aujourd'hui ?", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
67	1_550e8400-e29b-41d4-a716-446655440000	{"type": "human", "content": "ddadzax", "additional_kwargs": {}, "response_metadata": {}}
68	1_550e8400-e29b-41d4-a716-446655440000	{"type": "ai", "content": "Bonjour ! Je ne suis pas sûr de comprendre votre demande. Pourriez-vous préciser ou reformuler votre question ? Je suis là pour vous aider avec les questions techniques ou toute autre demande liée à WIDIP.", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
69	1_550e8400-e29b-41d4-a716-446655440000	{"type": "human", "content": "hey", "additional_kwargs": {}, "response_metadata": {}}
70	1_550e8400-e29b-41d4-a716-446655440000	{"type": "ai", "content": "Bonjour ! Comment puis-je vous aider aujourd'hui ?", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
71	1_963eb9f1-fdcc-4cd5-918b-29fae40c17a0	{"type": "human", "content": "dsf ça va ?", "additional_kwargs": {}, "response_metadata": {}}
72	1_963eb9f1-fdcc-4cd5-918b-29fae40c17a0	{"type": "ai", "content": "Bonjour ! Je vais très bien, merci de demander. 😊\\n\\nComment puis-je vous aider aujourd'hui ?", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
73	1_419ba4c9-f14d-4af2-83b3-ba2399c17ffb	{"type": "human", "content": "tu es tristes ?", "additional_kwargs": {}, "response_metadata": {}}
74	1_419ba4c9-f14d-4af2-83b3-ba2399c17ffb	{"type": "ai", "content": "Non, je ne suis pas triste. En tant qu'IA, je n'ai pas de sentiments ou d'émotions. Mon rôle est de vous aider avec vos questions techniques et de fournir des réponses claires et professionnelles. Comment puis-je vous aider aujourd'hui ?", "tool_calls": [], "additional_kwargs": {}, "response_metadata": {}, "invalid_tool_calls": []}
\.


--
-- Data for Name: oauth_access_tokens; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.oauth_access_tokens (token, "clientId", "userId") FROM stdin;
\.


--
-- Data for Name: oauth_authorization_codes; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.oauth_authorization_codes (code, "clientId", "userId", "redirectUri", "codeChallenge", "codeChallengeMethod", "expiresAt", state, used, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.oauth_clients (id, name, "redirectUris", "grantTypes", "clientSecret", "clientSecretExpiresAt", "tokenEndpointAuthMethod", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: oauth_refresh_tokens; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.oauth_refresh_tokens (token, "clientId", "userId", "expiresAt", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: oauth_user_consents; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.oauth_user_consents (id, "userId", "clientId", "grantedAt") FROM stdin;
\.


--
-- Data for Name: processed_data; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.processed_data ("workflowId", context, "createdAt", "updatedAt", value) FROM stdin;
\.


--
-- Data for Name: project; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.project (id, name, type, "createdAt", "updatedAt", icon, description) FROM stdin;
sxOW4Z7kldKTFN4J	Maxime Ripouteau <maximeripouteau@gmail.com>	personal	2025-12-26 07:42:27.834+00	2025-12-26 07:43:14.016+00	\N	\N
\.


--
-- Data for Name: project_relation; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.project_relation ("projectId", "userId", role, "createdAt", "updatedAt") FROM stdin;
sxOW4Z7kldKTFN4J	b5f4a6e2-7d01-4e13-8dd9-99a3dd8ace08	project:personalOwner	2025-12-26 07:42:27.834+00	2025-12-26 07:42:27.834+00
\.


--
-- Data for Name: role; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.role (slug, "displayName", description, "roleType", "systemRole", "createdAt", "updatedAt") FROM stdin;
global:owner	Owner	Owner	global	t	2025-12-26 07:42:28.692+00	2025-12-26 07:42:29.091+00
global:admin	Admin	Admin	global	t	2025-12-26 07:42:28.692+00	2025-12-26 07:42:29.091+00
global:member	Member	Member	global	t	2025-12-26 07:42:28.692+00	2025-12-26 07:42:29.091+00
project:admin	Project Admin	Full control of settings, members, workflows, credentials and executions	project	t	2025-12-26 07:42:28.692+00	2025-12-26 07:42:29.106+00
project:personalOwner	Project Owner	Project Owner	project	t	2025-12-26 07:42:28.692+00	2025-12-26 07:42:29.106+00
project:editor	Project Editor	Create, edit, and delete workflows, credentials, and executions	project	t	2025-12-26 07:42:28.692+00	2025-12-26 07:42:29.106+00
project:viewer	Project Viewer	Read-only access to workflows, credentials, and executions	project	t	2025-12-26 07:42:28.692+00	2025-12-26 07:42:29.106+00
credential:owner	Credential Owner	Credential Owner	credential	t	2025-12-26 07:42:29.115+00	2025-12-26 07:42:29.115+00
credential:user	Credential User	Credential User	credential	t	2025-12-26 07:42:29.115+00	2025-12-26 07:42:29.115+00
workflow:owner	Workflow Owner	Workflow Owner	workflow	t	2025-12-26 07:42:29.119+00	2025-12-26 07:42:29.119+00
workflow:editor	Workflow Editor	Workflow Editor	workflow	t	2025-12-26 07:42:29.119+00	2025-12-26 07:42:29.119+00
\.


--
-- Data for Name: role_scope; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.role_scope ("roleSlug", "scopeSlug") FROM stdin;
global:owner	annotationTag:create
global:owner	annotationTag:read
global:owner	annotationTag:update
global:owner	annotationTag:delete
global:owner	annotationTag:list
global:owner	auditLogs:manage
global:owner	banner:dismiss
global:owner	community:register
global:owner	communityPackage:install
global:owner	communityPackage:uninstall
global:owner	communityPackage:update
global:owner	communityPackage:list
global:owner	credential:share
global:owner	credential:shareGlobally
global:owner	credential:move
global:owner	credential:create
global:owner	credential:read
global:owner	credential:update
global:owner	credential:delete
global:owner	credential:list
global:owner	externalSecretsProvider:sync
global:owner	externalSecretsProvider:create
global:owner	externalSecretsProvider:read
global:owner	externalSecretsProvider:update
global:owner	externalSecretsProvider:delete
global:owner	externalSecretsProvider:list
global:owner	externalSecret:list
global:owner	externalSecret:use
global:owner	eventBusDestination:test
global:owner	eventBusDestination:create
global:owner	eventBusDestination:read
global:owner	eventBusDestination:update
global:owner	eventBusDestination:delete
global:owner	eventBusDestination:list
global:owner	ldap:sync
global:owner	ldap:manage
global:owner	license:manage
global:owner	logStreaming:manage
global:owner	orchestration:read
global:owner	project:create
global:owner	project:read
global:owner	project:update
global:owner	project:delete
global:owner	project:list
global:owner	saml:manage
global:owner	securityAudit:generate
global:owner	sourceControl:pull
global:owner	sourceControl:push
global:owner	sourceControl:manage
global:owner	tag:create
global:owner	tag:read
global:owner	tag:update
global:owner	tag:delete
global:owner	tag:list
global:owner	user:resetPassword
global:owner	user:changeRole
global:owner	user:enforceMfa
global:owner	user:create
global:owner	user:read
global:owner	user:update
global:owner	user:delete
global:owner	user:list
global:owner	variable:create
global:owner	variable:read
global:owner	variable:update
global:owner	variable:delete
global:owner	variable:list
global:owner	projectVariable:create
global:owner	projectVariable:read
global:owner	projectVariable:update
global:owner	projectVariable:delete
global:owner	projectVariable:list
global:owner	workersView:manage
global:owner	workflow:share
global:owner	workflow:execute
global:owner	workflow:move
global:owner	workflow:create
global:owner	workflow:read
global:owner	workflow:update
global:owner	workflow:delete
global:owner	workflow:list
global:owner	folder:create
global:owner	folder:read
global:owner	folder:update
global:owner	folder:delete
global:owner	folder:list
global:owner	folder:move
global:owner	insights:list
global:owner	oidc:manage
global:owner	provisioning:manage
global:owner	dataTable:create
global:owner	dataTable:read
global:owner	dataTable:update
global:owner	dataTable:delete
global:owner	dataTable:list
global:owner	dataTable:readRow
global:owner	dataTable:writeRow
global:owner	dataTable:listProject
global:owner	role:manage
global:owner	mcp:manage
global:owner	mcp:oauth
global:owner	mcpApiKey:create
global:owner	mcpApiKey:rotate
global:owner	chatHub:manage
global:owner	chatHub:message
global:owner	chatHubAgent:create
global:owner	chatHubAgent:read
global:owner	chatHubAgent:update
global:owner	chatHubAgent:delete
global:owner	chatHubAgent:list
global:owner	breakingChanges:list
global:admin	annotationTag:create
global:admin	annotationTag:read
global:admin	annotationTag:update
global:admin	annotationTag:delete
global:admin	annotationTag:list
global:admin	auditLogs:manage
global:admin	banner:dismiss
global:admin	community:register
global:admin	communityPackage:install
global:admin	communityPackage:uninstall
global:admin	communityPackage:update
global:admin	communityPackage:list
global:admin	credential:share
global:admin	credential:shareGlobally
global:admin	credential:move
global:admin	credential:create
global:admin	credential:read
global:admin	credential:update
global:admin	credential:delete
global:admin	credential:list
global:admin	externalSecretsProvider:sync
global:admin	externalSecretsProvider:create
global:admin	externalSecretsProvider:read
global:admin	externalSecretsProvider:update
global:admin	externalSecretsProvider:delete
global:admin	externalSecretsProvider:list
global:admin	externalSecret:list
global:admin	externalSecret:use
global:admin	eventBusDestination:test
global:admin	eventBusDestination:create
global:admin	eventBusDestination:read
global:admin	eventBusDestination:update
global:admin	eventBusDestination:delete
global:admin	eventBusDestination:list
global:admin	ldap:sync
global:admin	ldap:manage
global:admin	license:manage
global:admin	logStreaming:manage
global:admin	orchestration:read
global:admin	project:create
global:admin	project:read
global:admin	project:update
global:admin	project:delete
global:admin	project:list
global:admin	saml:manage
global:admin	securityAudit:generate
global:admin	sourceControl:pull
global:admin	sourceControl:push
global:admin	sourceControl:manage
global:admin	tag:create
global:admin	tag:read
global:admin	tag:update
global:admin	tag:delete
global:admin	tag:list
global:admin	user:resetPassword
global:admin	user:changeRole
global:admin	user:enforceMfa
global:admin	user:create
global:admin	user:read
global:admin	user:update
global:admin	user:delete
global:admin	user:list
global:admin	variable:create
global:admin	variable:read
global:admin	variable:update
global:admin	variable:delete
global:admin	variable:list
global:admin	projectVariable:create
global:admin	projectVariable:read
global:admin	projectVariable:update
global:admin	projectVariable:delete
global:admin	projectVariable:list
global:admin	workersView:manage
global:admin	workflow:share
global:admin	workflow:execute
global:admin	workflow:move
global:admin	workflow:create
global:admin	workflow:read
global:admin	workflow:update
global:admin	workflow:delete
global:admin	workflow:list
global:admin	folder:create
global:admin	folder:read
global:admin	folder:update
global:admin	folder:delete
global:admin	folder:list
global:admin	folder:move
global:admin	insights:list
global:admin	oidc:manage
global:admin	provisioning:manage
global:admin	dataTable:create
global:admin	dataTable:read
global:admin	dataTable:update
global:admin	dataTable:delete
global:admin	dataTable:list
global:admin	dataTable:readRow
global:admin	dataTable:writeRow
global:admin	dataTable:listProject
global:admin	role:manage
global:admin	mcp:manage
global:admin	mcp:oauth
global:admin	mcpApiKey:create
global:admin	mcpApiKey:rotate
global:admin	chatHub:manage
global:admin	chatHub:message
global:admin	chatHubAgent:create
global:admin	chatHubAgent:read
global:admin	chatHubAgent:update
global:admin	chatHubAgent:delete
global:admin	chatHubAgent:list
global:admin	breakingChanges:list
global:member	annotationTag:create
global:member	annotationTag:read
global:member	annotationTag:update
global:member	annotationTag:delete
global:member	annotationTag:list
global:member	eventBusDestination:test
global:member	eventBusDestination:list
global:member	tag:create
global:member	tag:read
global:member	tag:update
global:member	tag:list
global:member	user:list
global:member	variable:read
global:member	variable:list
global:member	dataTable:list
global:member	mcp:oauth
global:member	mcpApiKey:create
global:member	mcpApiKey:rotate
global:member	chatHub:message
global:member	chatHubAgent:create
global:member	chatHubAgent:read
global:member	chatHubAgent:update
global:member	chatHubAgent:delete
global:member	chatHubAgent:list
project:admin	credential:share
project:admin	credential:move
project:admin	credential:create
project:admin	credential:read
project:admin	credential:update
project:admin	credential:delete
project:admin	credential:list
project:admin	project:read
project:admin	project:update
project:admin	project:delete
project:admin	project:list
project:admin	sourceControl:push
project:admin	projectVariable:create
project:admin	projectVariable:read
project:admin	projectVariable:update
project:admin	projectVariable:delete
project:admin	projectVariable:list
project:admin	workflow:execute
project:admin	workflow:move
project:admin	workflow:create
project:admin	workflow:read
project:admin	workflow:update
project:admin	workflow:delete
project:admin	workflow:list
project:admin	folder:create
project:admin	folder:read
project:admin	folder:update
project:admin	folder:delete
project:admin	folder:list
project:admin	folder:move
project:admin	dataTable:create
project:admin	dataTable:read
project:admin	dataTable:update
project:admin	dataTable:delete
project:admin	dataTable:readRow
project:admin	dataTable:writeRow
project:admin	dataTable:listProject
project:personalOwner	credential:share
project:personalOwner	credential:move
project:personalOwner	credential:create
project:personalOwner	credential:read
project:personalOwner	credential:update
project:personalOwner	credential:delete
project:personalOwner	credential:list
project:personalOwner	project:read
project:personalOwner	project:list
project:personalOwner	workflow:share
project:personalOwner	workflow:execute
project:personalOwner	workflow:move
project:personalOwner	workflow:create
project:personalOwner	workflow:read
project:personalOwner	workflow:update
project:personalOwner	workflow:delete
project:personalOwner	workflow:list
project:personalOwner	folder:create
project:personalOwner	folder:read
project:personalOwner	folder:update
project:personalOwner	folder:delete
project:personalOwner	folder:list
project:personalOwner	folder:move
project:personalOwner	dataTable:create
project:personalOwner	dataTable:read
project:personalOwner	dataTable:update
project:personalOwner	dataTable:delete
project:personalOwner	dataTable:readRow
project:personalOwner	dataTable:writeRow
project:personalOwner	dataTable:listProject
project:editor	credential:create
project:editor	credential:read
project:editor	credential:update
project:editor	credential:delete
project:editor	credential:list
project:editor	project:read
project:editor	project:list
project:editor	projectVariable:create
project:editor	projectVariable:read
project:editor	projectVariable:update
project:editor	projectVariable:delete
project:editor	projectVariable:list
project:editor	workflow:execute
project:editor	workflow:create
project:editor	workflow:read
project:editor	workflow:update
project:editor	workflow:delete
project:editor	workflow:list
project:editor	folder:create
project:editor	folder:read
project:editor	folder:update
project:editor	folder:delete
project:editor	folder:list
project:editor	dataTable:create
project:editor	dataTable:read
project:editor	dataTable:update
project:editor	dataTable:delete
project:editor	dataTable:readRow
project:editor	dataTable:writeRow
project:editor	dataTable:listProject
project:viewer	credential:read
project:viewer	credential:list
project:viewer	project:read
project:viewer	project:list
project:viewer	projectVariable:read
project:viewer	projectVariable:list
project:viewer	workflow:read
project:viewer	workflow:list
project:viewer	folder:read
project:viewer	folder:list
project:viewer	dataTable:read
project:viewer	dataTable:readRow
project:viewer	dataTable:listProject
credential:owner	credential:share
credential:owner	credential:move
credential:owner	credential:read
credential:owner	credential:update
credential:owner	credential:delete
credential:user	credential:read
workflow:owner	workflow:share
workflow:owner	workflow:execute
workflow:owner	workflow:move
workflow:owner	workflow:read
workflow:owner	workflow:update
workflow:owner	workflow:delete
workflow:editor	workflow:execute
workflow:editor	workflow:read
workflow:editor	workflow:update
\.


--
-- Data for Name: scope; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.scope (slug, "displayName", description) FROM stdin;
annotationTag:create	Create Annotation Tag	Allows creating new annotation tags.
annotationTag:read	annotationTag:read	\N
annotationTag:update	annotationTag:update	\N
annotationTag:delete	annotationTag:delete	\N
annotationTag:list	annotationTag:list	\N
annotationTag:*	annotationTag:*	\N
auditLogs:manage	auditLogs:manage	\N
auditLogs:*	auditLogs:*	\N
banner:dismiss	banner:dismiss	\N
banner:*	banner:*	\N
community:register	community:register	\N
community:*	community:*	\N
communityPackage:install	communityPackage:install	\N
communityPackage:uninstall	communityPackage:uninstall	\N
communityPackage:update	communityPackage:update	\N
communityPackage:list	communityPackage:list	\N
communityPackage:manage	communityPackage:manage	\N
communityPackage:*	communityPackage:*	\N
credential:share	credential:share	\N
credential:shareGlobally	credential:shareGlobally	\N
credential:move	credential:move	\N
credential:create	credential:create	\N
credential:read	credential:read	\N
credential:update	credential:update	\N
credential:delete	credential:delete	\N
credential:list	credential:list	\N
credential:*	credential:*	\N
externalSecretsProvider:sync	externalSecretsProvider:sync	\N
externalSecretsProvider:create	externalSecretsProvider:create	\N
externalSecretsProvider:read	externalSecretsProvider:read	\N
externalSecretsProvider:update	externalSecretsProvider:update	\N
externalSecretsProvider:delete	externalSecretsProvider:delete	\N
externalSecretsProvider:list	externalSecretsProvider:list	\N
externalSecretsProvider:*	externalSecretsProvider:*	\N
externalSecret:list	externalSecret:list	\N
externalSecret:use	externalSecret:use	\N
externalSecret:*	externalSecret:*	\N
eventBusDestination:test	eventBusDestination:test	\N
eventBusDestination:create	eventBusDestination:create	\N
eventBusDestination:read	eventBusDestination:read	\N
eventBusDestination:update	eventBusDestination:update	\N
eventBusDestination:delete	eventBusDestination:delete	\N
eventBusDestination:list	eventBusDestination:list	\N
eventBusDestination:*	eventBusDestination:*	\N
ldap:sync	ldap:sync	\N
ldap:manage	ldap:manage	\N
ldap:*	ldap:*	\N
license:manage	license:manage	\N
license:*	license:*	\N
logStreaming:manage	logStreaming:manage	\N
logStreaming:*	logStreaming:*	\N
orchestration:read	orchestration:read	\N
orchestration:list	orchestration:list	\N
orchestration:*	orchestration:*	\N
project:create	project:create	\N
project:read	project:read	\N
project:update	project:update	\N
project:delete	project:delete	\N
project:list	project:list	\N
project:*	project:*	\N
saml:manage	saml:manage	\N
saml:*	saml:*	\N
securityAudit:generate	securityAudit:generate	\N
securityAudit:*	securityAudit:*	\N
sourceControl:pull	sourceControl:pull	\N
sourceControl:push	sourceControl:push	\N
sourceControl:manage	sourceControl:manage	\N
sourceControl:*	sourceControl:*	\N
tag:create	tag:create	\N
tag:read	tag:read	\N
tag:update	tag:update	\N
tag:delete	tag:delete	\N
tag:list	tag:list	\N
tag:*	tag:*	\N
user:resetPassword	user:resetPassword	\N
user:changeRole	user:changeRole	\N
user:enforceMfa	user:enforceMfa	\N
user:create	user:create	\N
user:read	user:read	\N
user:update	user:update	\N
user:delete	user:delete	\N
user:list	user:list	\N
user:*	user:*	\N
variable:create	variable:create	\N
variable:read	variable:read	\N
variable:update	variable:update	\N
variable:delete	variable:delete	\N
variable:list	variable:list	\N
variable:*	variable:*	\N
projectVariable:create	projectVariable:create	\N
projectVariable:read	projectVariable:read	\N
projectVariable:update	projectVariable:update	\N
projectVariable:delete	projectVariable:delete	\N
projectVariable:list	projectVariable:list	\N
projectVariable:*	projectVariable:*	\N
workersView:manage	workersView:manage	\N
workersView:*	workersView:*	\N
workflow:share	workflow:share	\N
workflow:execute	workflow:execute	\N
workflow:move	workflow:move	\N
workflow:activate	workflow:activate	\N
workflow:deactivate	workflow:deactivate	\N
workflow:create	workflow:create	\N
workflow:read	workflow:read	\N
workflow:update	workflow:update	\N
workflow:delete	workflow:delete	\N
workflow:list	workflow:list	\N
workflow:*	workflow:*	\N
folder:create	folder:create	\N
folder:read	folder:read	\N
folder:update	folder:update	\N
folder:delete	folder:delete	\N
folder:list	folder:list	\N
folder:move	folder:move	\N
folder:*	folder:*	\N
insights:list	insights:list	\N
insights:*	insights:*	\N
oidc:manage	oidc:manage	\N
oidc:*	oidc:*	\N
provisioning:manage	provisioning:manage	\N
provisioning:*	provisioning:*	\N
dataTable:create	dataTable:create	\N
dataTable:read	dataTable:read	\N
dataTable:update	dataTable:update	\N
dataTable:delete	dataTable:delete	\N
dataTable:list	dataTable:list	\N
dataTable:readRow	dataTable:readRow	\N
dataTable:writeRow	dataTable:writeRow	\N
dataTable:listProject	dataTable:listProject	\N
dataTable:*	dataTable:*	\N
execution:delete	execution:delete	\N
execution:read	execution:read	\N
execution:retry	execution:retry	\N
execution:list	execution:list	\N
execution:get	execution:get	\N
execution:*	execution:*	\N
workflowTags:update	workflowTags:update	\N
workflowTags:list	workflowTags:list	\N
workflowTags:*	workflowTags:*	\N
role:manage	role:manage	\N
role:*	role:*	\N
mcp:manage	mcp:manage	\N
mcp:oauth	mcp:oauth	\N
mcp:*	mcp:*	\N
mcpApiKey:create	mcpApiKey:create	\N
mcpApiKey:rotate	mcpApiKey:rotate	\N
mcpApiKey:*	mcpApiKey:*	\N
chatHub:manage	chatHub:manage	\N
chatHub:message	chatHub:message	\N
chatHub:*	chatHub:*	\N
chatHubAgent:create	chatHubAgent:create	\N
chatHubAgent:read	chatHubAgent:read	\N
chatHubAgent:update	chatHubAgent:update	\N
chatHubAgent:delete	chatHubAgent:delete	\N
chatHubAgent:list	chatHubAgent:list	\N
chatHubAgent:*	chatHubAgent:*	\N
breakingChanges:list	breakingChanges:list	\N
breakingChanges:*	breakingChanges:*	\N
*	*	\N
\.


--
-- Data for Name: settings; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.settings (key, value, "loadOnStartup") FROM stdin;
ui.banners.dismissed	["V1"]	t
features.ldap	{"loginEnabled":false,"loginLabel":"","connectionUrl":"","allowUnauthorizedCerts":false,"connectionSecurity":"none","connectionPort":389,"baseDn":"","bindingAdminDn":"","bindingAdminPassword":"","firstNameAttribute":"","lastNameAttribute":"","emailAttribute":"","loginIdAttribute":"","ldapIdAttribute":"","userFilter":"","synchronizationEnabled":false,"synchronizationInterval":60,"searchPageSize":0,"searchTimeout":60,"enforceEmailUniqueness":true}	t
userManagement.authenticationMethod	email	t
features.sourceControl.sshKeys	{"encryptedPrivateKey":"U2FsdGVkX1+Bvxz2Uq4nhlWUUIy5MMDX8BlsknwovoIw3hIkYfb0Vhxum+ajT8eVqRwpnbcAkAAaHqbnjMxHtlVVfFZKg/6NsHla+Sa9qJ3HGy0dgMcBF23w1MY79tEkaBCT0ah30H3WCC+78gUr293OkaXT/F9Qjo5kLlmNTxyXRe9hN+vNwVPZXF4UccBUNlaoDVaqfHXHr2MBKpgYZ1YElRB1VrFxqrFTZ/yV3hPwPPzPv9fyMogGUbEzmCR/Y1slpZDUiN9UrOGyMkskU6AU9n2XfxexoUweoa7sDzPY0bhCqnrhlI7ikM8GyP1m1mARZR4GfXUYIQEphNFO0Cg4oeVJxaV6vOSu71s8Hj4qaEcFNEjw8SCLRMqXCFp9KgGnaStGJTiliS11L4paSbSsy9X60xFjGHsD3ch8nogAeOErR1gzcUyaKnQEXIwHFOgWw4WGcdPSJ6VXDkgNflturN/ayt5zI0/CSE7hgNN27ed000Bau5d4WCVvQowh/aL3c7O0eRChKo7xNuT1epWWxxNtcuOGZB+fuC9iZ7QYT2CLa9WpmAwOi8VDiwbz","publicKey":"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJi4R658iQS1FLrIylJz4KcbR0Wc9xSWKP+GMdEpIeSg n8n deploy key"}	t
features.sourceControl	{"branchName":"main","connectionType":"ssh","keyGeneratorType":"ed25519"}	t
userManagement.isInstanceOwnerSetUp	true	t
\.


--
-- Data for Name: shared_credentials; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.shared_credentials ("credentialsId", "projectId", role, "createdAt", "updatedAt") FROM stdin;
b9hl3JA2taufCYVr	sxOW4Z7kldKTFN4J	credential:owner	2025-12-26 07:45:05.04+00	2025-12-26 07:45:05.04+00
yY2GzRzLXTG4anFZ	sxOW4Z7kldKTFN4J	credential:owner	2025-12-26 07:46:04.383+00	2025-12-26 07:46:04.383+00
Wzf3r27D8BuEckRY	sxOW4Z7kldKTFN4J	credential:owner	2025-12-26 08:58:11.402+00	2025-12-26 08:58:11.402+00
\.


--
-- Data for Name: shared_workflow; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.shared_workflow ("workflowId", "projectId", role, "createdAt", "updatedAt") FROM stdin;
zZSHB9BHjR30ThPP	sxOW4Z7kldKTFN4J	workflow:owner	2025-12-26 17:23:18.804+00	2025-12-26 17:23:18.804+00
NynEDh5rxUQL7788	sxOW4Z7kldKTFN4J	workflow:owner	2025-12-26 17:23:30.579+00	2025-12-26 17:23:30.579+00
oJ8RPfYOe0ed1LSJ	sxOW4Z7kldKTFN4J	workflow:owner	2025-12-26 17:23:38.667+00	2025-12-26 17:23:38.667+00
yPYTzGXVRP2JQxs8	sxOW4Z7kldKTFN4J	workflow:owner	2025-12-26 17:23:46.197+00	2025-12-26 17:23:46.197+00
c8fbjjX9ObuzBE4b	sxOW4Z7kldKTFN4J	workflow:owner	2025-12-26 17:24:01.471+00	2025-12-26 17:24:01.471+00
msg5c740bd9db51	sxOW4Z7kldKTFN4J	workflow:owner	2025-12-26 17:58:16.107+00	2025-12-26 17:58:16.107+00
\.


--
-- Data for Name: tag_entity; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.tag_entity (name, "createdAt", "updatedAt", id) FROM stdin;
WIBOT	2025-12-26 07:43:51.869+00	2025-12-26 07:43:51.869+00	kqzTIvUMe4tyfHJb
\.


--
-- Data for Name: test_case_execution; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.test_case_execution (id, "testRunId", "executionId", status, "runAt", "completedAt", "errorCode", "errorDetails", metrics, "createdAt", "updatedAt", inputs, outputs) FROM stdin;
\.


--
-- Data for Name: test_run; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.test_run (id, "workflowId", status, "errorCode", "errorDetails", "runAt", "completedAt", metrics, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public."user" (id, email, "firstName", "lastName", password, "personalizationAnswers", "createdAt", "updatedAt", settings, disabled, "mfaEnabled", "mfaSecret", "mfaRecoveryCodes", "lastActiveAt", "roleSlug") FROM stdin;
b5f4a6e2-7d01-4e13-8dd9-99a3dd8ace08	maximeripouteau@gmail.com	Maxime	Ripouteau	$2a$10$c2eAVPikiYMYpLvVWI/Snuvm28xujCDI1hy9EW3tXhIRMwIQO2Gle	{"version":"v4","personalization_survey_submitted_at":"2025-12-26T07:43:34.725Z","personalization_survey_n8n_version":"1.122.4","companySize":"20-99","companyType":"saas","role":"customer-support","reportedSource":"google"}	2025-12-26 07:42:26.892+00	2025-12-26 18:15:23.688+00	{"userActivated":true,"easyAIWorkflowOnboarded":true,"firstSuccessfulWorkflowId":"S6pj8R0aLVT6xis5","userActivatedAt":1766736386935}	f	f	\N	\N	2025-12-26	global:owner
\.


--
-- Data for Name: user_api_keys; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.user_api_keys (id, "userId", label, "apiKey", "createdAt", "updatedAt", scopes, audience) FROM stdin;
\.


--
-- Data for Name: user_token_usage; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.user_token_usage (usage_id, user_id, month, used_tokens, quota_tokens) FROM stdin;
1	1	2025-12-01	14353	50000
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.users (user_id, username, password_hash, email, role, created_at, is_active) FROM stdin;
1	khora	test123	khora@widip.fr	admin	2025-12-26 07:42:15.244901	t
2	test	test123	test@widip.fr	user	2025-12-26 07:42:15.246796	t
\.


--
-- Data for Name: variables; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.variables (key, type, value, id, "projectId") FROM stdin;
\.


--
-- Data for Name: webhook_entity; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.webhook_entity ("webhookPath", method, node, "webhookId", "pathLength", "workflowId") FROM stdin;
auth/login	POST	Webhook Login	\N	\N	zZSHB9BHjR30ThPP
wibot/chat	POST	Webhook Chat	\N	\N	NynEDh5rxUQL7788
wibot/conversations	POST	Webhook	\N	\N	oJ8RPfYOe0ed1LSJ
wibot/conversations	GET	Webhook	\N	\N	yPYTzGXVRP2JQxs8
wibot/user/tokens	GET	Webhook	\N	\N	c8fbjjX9ObuzBE4b
wibot/messages	GET	Webhook	wibot-messages	\N	msg5c740bd9db51
\.


--
-- Data for Name: workflow_dependency; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.workflow_dependency (id, "workflowId", "workflowVersionId", "dependencyType", "dependencyKey", "dependencyInfo", "indexVersionId", "createdAt") FROM stdin;
\.


--
-- Data for Name: workflow_entity; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.workflow_entity (name, active, nodes, connections, "createdAt", "updatedAt", settings, "staticData", "pinData", "versionId", "triggerCount", id, meta, "parentFolderId", "isArchived", "versionCounter", description, "activeVersionId") FROM stdin;
WIBOT - Auth Login	t	[{"parameters":{"httpMethod":"POST","path":"auth/login","responseMode":"responseNode","options":{}},"id":"c8898033-10a2-436a-915d-a01f108756c6","name":"Webhook Login","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-1104,208],"webhookId":"auth-login"},{"parameters":{"operation":"select","schema":"public","table":"users","limit":1,"where":{"values":[{"column":"username","value":"={{ $json.body.username }}"},{"column":"is_active","value":"true"}]},"options":{}},"id":"a2a158de-b676-468b-a23e-18466966d674","name":"Get User","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[-880,208],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-user-exists","leftValue":"={{ $json.user_id }}","rightValue":"","operator":{"type":"exists","operation":"exists"}}],"combinator":"and"},"options":{}},"id":"dd3f022d-09ed-47fe-ba59-73ae33165762","name":"User Exists?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-656,208]},{"parameters":{"jsCode":"const inputPassword = $('Webhook Login').first().json.body.password;\\nconst storedHash = $input.first().json.password_hash;\\nconst user = $input.first().json;\\n\\n// Comparaison simple du mot de passe\\nconst isValid = (inputPassword === storedHash);\\n\\nreturn [{ json: { isValid, user } }];"},"id":"bb41f913-1c3c-4afb-88a4-c46324c2b9ec","name":"Verify Password","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-password-valid","leftValue":"={{ $json.isValid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"73c0896e-95a9-4677-86c9-3398d7856fad","name":"Password Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"jsCode":"const user = $input.first().json.user;\\n\\n// Fonction base64 encode compatible n8n\\nfunction toBase64(str) {\\n  return Buffer.from(str).toString('base64').replace(/=/g, '').replace(/\\\\+/g, '-').replace(/\\\\//g, '_');\\n}\\n\\nconst header = toBase64(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));\\n\\nconst payload = toBase64(JSON.stringify({\\n  userId: user.user_id,\\n  username: user.username,\\n  role: user.role,\\n  iat: Math.floor(Date.now() / 1000),\\n  exp: Math.floor(Date.now() / 1000) + (24 * 60 * 60)\\n}));\\n\\n// Signature simplifiée\\nconst signature = toBase64(header + payload + 'wibot_secret').substring(0, 43);\\n\\nconst token = `${header}.${payload}.${signature}`;\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    token,\\n    user: {\\n      id: user.user_id,\\n      username: user.username,\\n      role: user.role\\n    }\\n  }\\n}];"},"id":"56756190-1aeb-4413-946a-e2a7b4907e8e","name":"Generate JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[0,0]},{"parameters":{"respondWith":"json","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"5e5d60cc-5fee-4f26-b838-71d66c7a885a","name":"Success Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[224,0]},{"parameters":{"respondWith":"json","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"Invalid credentials\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"e90d3bbc-527a-4b00-b1dc-9bb17afa5966","name":"Invalid Password","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,208]},{"parameters":{"respondWith":"json","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"User not found\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"8423d2d4-a607-49d0-a6d7-8730cf78fd86","name":"User Not Found","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[-448,304]}]	{"Webhook Login":{"main":[[{"node":"Get User","type":"main","index":0}]]},"Get User":{"main":[[{"node":"User Exists?","type":"main","index":0}]]},"User Exists?":{"main":[[{"node":"Verify Password","type":"main","index":0}],[{"node":"User Not Found","type":"main","index":0}]]},"Verify Password":{"main":[[{"node":"Password Valid?","type":"main","index":0}]]},"Password Valid?":{"main":[[{"node":"Generate JWT","type":"main","index":0}],[{"node":"Invalid Password","type":"main","index":0}]]},"Generate JWT":{"main":[[{"node":"Success Response","type":"main","index":0}]]}}	2025-12-26 17:23:18.804+00	2025-12-26 17:24:10.395+00	{"executionOrder":"v1"}	\N	{}	1e31f7d7-5e68-47eb-863c-91d1ec7b0819	1	zZSHB9BHjR30ThPP	{"templateCredsSetupCompleted":true}	\N	f	12	\N	1e31f7d7-5e68-47eb-863c-91d1ec7b0819
WIBOT - Get Conversations	t	[{"parameters":{"path":"wibot/conversations","responseMode":"responseNode","options":{}},"id":"c0f9fbaf-d0bb-4e86-92e9-c3e34e750679","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-656,112],"webhookId":"wibot-conversations"},{"parameters":{"jsCode":"const authHeader = $input.first().json.headers.authorization;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}"},"id":"a5bd8ac1-82cc-4021-8420-752f46440f49","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"352ea961-e9a7-4651-acad-b594ba9f1c8c","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"respondWith":"json","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"9a0fd5d7-2e41-4111-b2b2-f84c1403ea28","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"operation":"executeQuery","query":"SELECT \\n  c.conversation_id::text,\\n  c.title,\\n  TO_CHAR(c.updated_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as updated_at,\\n  COUNT(m.message_id)::integer as message_count\\nFROM conversations c\\nLEFT JOIN messages m ON c.conversation_id = m.conversation_id\\nWHERE c.user_id = {{ $json.userId }}\\nGROUP BY c.conversation_id, c.title, c.updated_at\\nORDER BY c.updated_at DESC\\nLIMIT 50;","options":{}},"id":"8fe150d4-0f4e-41ac-bd90-8978f31f4459","name":"Get Conversations","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[0,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats ou resultats vides\\nif (!rows || rows.length === 0 || !rows[0].json.conversation_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      conversations: []\\n    }\\n  }];\\n}\\n\\nconst conversations = rows.map(row => ({\\n  conversation_id: row.json.conversation_id,\\n  title: row.json.title || 'Nouvelle conversation',\\n  updated_at: row.json.updated_at,\\n  message_count: parseInt(row.json.message_count) || 0\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    conversations\\n  }\\n}];"},"id":"8d9137c5-9aa8-4938-961f-50bdbc93ee8f","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"respondWith":"json","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"463fcf83-1d8e-472a-94df-623b505f1a5d","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[448,0]}]	{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Conversations","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Conversations":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}}	2025-12-26 17:23:46.197+00	2025-12-26 17:24:07.735+00	{"executionOrder":"v1"}	\N	{}	e1bae720-4a31-4afe-a595-4a35f7e26b0f	1	yPYTzGXVRP2JQxs8	{"templateCredsSetupCompleted":true}	\N	f	12	\N	e1bae720-4a31-4afe-a595-4a35f7e26b0f
WIBOT - Get User Tokens	t	[{"parameters":{"path":"wibot/user/tokens","responseMode":"responseNode","options":{}},"id":"8fcee23f-b3e4-4c28-ad04-4ba456f7752a","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-656,112],"webhookId":"wibot-user-tokens"},{"parameters":{"jsCode":"const authHeader = $input.first().json.headers.authorization;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}"},"id":"d8de2cd5-94e4-49a5-a318-1ee1c389abd9","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"c9c309e4-53ba-46be-8960-13da82f4f5f7","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"respondWith":"json","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"83cd3ac8-fb46-4de5-a8ce-5d24be08334c","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"operation":"executeQuery","query":"SELECT \\n  COALESCE(used_tokens, 0) as used_tokens,\\n  COALESCE(quota_tokens, 50000) as quota_tokens,\\n  COALESCE(quota_tokens, 50000) - COALESCE(used_tokens, 0) as tokens_remaining\\nFROM user_token_usage\\nWHERE user_id = {{ $json.userId }}\\n  AND month = DATE_TRUNC('month', CURRENT_DATE)\\nLIMIT 1;","options":{}},"id":"b35fa964-24c4-49ed-a3b6-7df917662ceb","name":"Get Token Usage","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[0,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"jsCode":"const rows = $input.all();\\nconst jwtData = $('Verify JWT').first().json;\\n\\n// Si pas de donnees, l'utilisateur n'a pas encore utilise de tokens ce mois\\nif (!rows || rows.length === 0 || rows[0].json.tokens_remaining === undefined) {\\n  return [{\\n    json: {\\n      success: true,\\n      used_tokens: 0,\\n      quota_tokens: 50000,\\n      tokens_remaining: 50000\\n    }\\n  }];\\n}\\n\\nconst data = rows[0].json;\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    used_tokens: parseInt(data.used_tokens) || 0,\\n    quota_tokens: parseInt(data.quota_tokens) || 50000,\\n    tokens_remaining: parseInt(data.tokens_remaining) || 50000\\n  }\\n}];"},"id":"7d9b1764-6fed-49d3-957f-402aa7f05696","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"respondWith":"json","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"67daad4e-a2fe-4b36-b18c-065181b80de3","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[448,0]}]	{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Token Usage","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Token Usage":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}}	2025-12-26 17:24:01.471+00	2025-12-26 17:24:05.529+00	{"executionOrder":"v1"}	\N	{}	62643582-5e10-4f85-9c6c-74a85d102e67	1	c8fbjjX9ObuzBE4b	{"templateCredsSetupCompleted":true}	\N	f	12	\N	62643582-5e10-4f85-9c6c-74a85d102e67
WIBOT - Get Messages	t	[{"parameters": {"httpMethod": "GET", "path": "wibot/messages", "responseMode": "responseNode", "options": {}}, "id": "webhook-messages", "name": "Webhook", "type": "n8n-nodes-base.webhook", "typeVersion": 2, "position": [250, 300], "webhookId": "wibot-messages"}, {"parameters": {"jsCode": "const authHeader = $input.first().json.headers.authorization;\\nconst conversationId = $input.first().json.query.conversationId;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nif (!conversationId) {\\n  return [{ json: { valid: false, error: 'conversationId is required' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId, conversationId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}"}, "id": "verify-jwt", "name": "Verify JWT", "type": "n8n-nodes-base.code", "typeVersion": 2, "position": [470, 300]}, {"parameters": {"conditions": {"options": {"caseSensitive": true, "leftValue": "", "typeValidation": "strict"}, "conditions": [{"id": "check-jwt-valid", "leftValue": "={{ $json.valid }}", "rightValue": true, "operator": {"type": "boolean", "operation": "equals"}}], "combinator": "and"}, "options": {}}, "id": "if-jwt-valid", "name": "JWT Valid?", "type": "n8n-nodes-base.if", "typeVersion": 2, "position": [690, 300]}, {"parameters": {"respondWith": "json", "responseBody": "={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}", "options": {"responseCode": 401, "responseHeaders": {"entries": [{"name": "Content-Type", "value": "application/json"}]}}}, "id": "respond-unauthorized", "name": "Unauthorized", "type": "n8n-nodes-base.respondToWebhook", "typeVersion": 1.1, "position": [910, 450]}, {"parameters": {"operation": "executeQuery", "query": "SELECT \\n  m.message_id,\\n  m.role,\\n  m.content,\\n  TO_CHAR(m.created_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as created_at\\nFROM messages m\\nJOIN conversations c ON m.conversation_id = c.conversation_id\\nWHERE m.conversation_id = '{{ $json.conversationId }}'::uuid\\n  AND c.user_id = {{ $json.userId }}\\nORDER BY m.created_at ASC;", "options": {}}, "id": "get-messages", "name": "Get Messages", "type": "n8n-nodes-base.postgres", "typeVersion": 2.5, "position": [910, 200], "credentials": {"postgres": {"id": "yY2GzRzLXTG4anFZ", "name": "WIBOT PostgreSQL"}}}, {"parameters": {"jsCode": "const rows = $input.all();\\n\\n// Si pas de resultats, retourner liste vide\\nif (!rows || rows.length === 0 || !rows[0].json.message_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      messages: []\\n    }\\n  }];\\n}\\n\\nconst messages = rows.map(row => ({\\n  message_id: row.json.message_id,\\n  role: row.json.role,\\n  content: row.json.content,\\n  created_at: row.json.created_at\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    messages\\n  }\\n}];"}, "id": "format-response", "name": "Format Response", "type": "n8n-nodes-base.code", "typeVersion": 2, "position": [1130, 200]}, {"parameters": {"respondWith": "json", "responseBody": "={{ $json }}", "options": {"responseCode": 200, "responseHeaders": {"entries": [{"name": "Content-Type", "value": "application/json"}]}}}, "id": "respond-success", "name": "Success", "type": "n8n-nodes-base.respondToWebhook", "typeVersion": 1.1, "position": [1350, 200]}]	{"Webhook": {"main": [[{"node": "Verify JWT", "type": "main", "index": 0}]]}, "Verify JWT": {"main": [[{"node": "JWT Valid?", "type": "main", "index": 0}]]}, "JWT Valid?": {"main": [[{"node": "Get Messages", "type": "main", "index": 0}], [{"node": "Unauthorized", "type": "main", "index": 0}]]}, "Get Messages": {"main": [[{"node": "Format Response", "type": "main", "index": 0}]]}, "Format Response": {"main": [[{"node": "Success", "type": "main", "index": 0}]]}}	2025-12-26 17:58:10.218+00	2025-12-26 17:58:10.218+00	{"executionOrder": "v1"}	null	{}	704bc444-e5e2-4901-9322-383bc1bd0434	1	msg5c740bd9db51	\N	\N	f	3	\N	704bc444-e5e2-4901-9322-383bc1bd0434
WIBOT - Chat Main	t	[{"parameters":{"httpMethod":"POST","path":"wibot/chat","responseMode":"responseNode","options":{}},"id":"fa8ec4be-706d-4001-ad6c-fcb0f99736af","name":"Webhook Chat","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-1328,112],"webhookId":"wibot-chat"},{"parameters":{"jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst body = $input.first().json.body;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  // Decode base64url payload\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  // Check expiration\\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ \\n    json: { \\n      valid: true, \\n      user: decoded,\\n      userId: decoded.userId,\\n      conversationId: body.conversation_id,\\n      message: body.message,\\n      sessionId: `${decoded.userId}_${body.conversation_id}`\\n    } \\n  }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}"},"id":"0004c18c-eca3-41dc-997e-590e7fd79356","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-1104,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"bfcef1a4-73b6-486c-aab3-5977d98eb079","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-880,112]},{"parameters":{"respondWith":"json","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"cba8bdb1-b75a-4f70-aa59-b7a0eda05fa5","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[-656,352]},{"parameters":{"operation":"executeQuery","query":"SELECT \\n  COALESCE(used_tokens, 0) as used_tokens,\\n  COALESCE(quota_tokens, 50000) as quota_tokens\\nFROM user_token_usage\\nWHERE user_id = {{ $json.userId }}\\n  AND month = DATE_TRUNC('month', CURRENT_DATE)\\nLIMIT 1;","options":{}},"id":"c95bf25e-6737-45ac-a7bb-499bc0b7c7dc","name":"Check Quota","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[-656,112],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"jsCode":"const rows = $input.all();\\nconst jwtData = $('Verify JWT').first().json;\\n\\nlet usedTokens = 0;\\nlet quotaTokens = 50000;\\n\\nif (rows && rows.length > 0 && rows[0].json.used_tokens !== undefined) {\\n  usedTokens = parseInt(rows[0].json.used_tokens) || 0;\\n  quotaTokens = parseInt(rows[0].json.quota_tokens) || 50000;\\n}\\n\\nconst quotaExceeded = usedTokens >= quotaTokens;\\n\\nreturn [{\\n  json: {\\n    ...jwtData,\\n    usedTokens,\\n    quotaTokens,\\n    quotaExceeded\\n  }\\n}];"},"id":"4a1c034d-d824-4eec-8f7d-30e703f1deb5","name":"Prepare Quota","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-quota-ok","leftValue":"={{ $json.quotaExceeded }}","rightValue":false,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"19cfec26-6daa-4bf5-a4dd-9c46bc7e775a","name":"Quota OK?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"respondWith":"json","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"Quota tokens mensuel depass\\\\u00e9. Limite : 50,000 tokens/mois.\\",\\n  \\"code\\": \\"QUOTA_EXCEEDED\\"\\n}","options":{"responseCode":429,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"664cd109-b947-42ee-b8c1-42b595e37b31","name":"Quota Exceeded","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"promptType":"define","text":"={{ $json.message }}","options":{"systemMessage":"Tu es WIBOT, l'assistant IA interne de WIDIP, une entreprise francaise de services informatiques.\\n\\nTon role:\\n- Aider les employes WIDIP avec leurs questions techniques\\n- Fournir des reponses claires et professionnelles\\n- Utiliser le francais par defaut\\n- Etre concis mais complet\\n\\nStyle:\\n- Utilise le markdown pour formater tes reponses\\n- Mets le code dans des blocs avec le langage specifie\\n- Sois amical mais professionnel"}},"id":"9e04ca0c-5683-4a62-828d-5c057cf62605","name":"AI Agent","type":"@n8n/n8n-nodes-langchain.agent","typeVersion":1.7,"position":[0,0]},{"parameters":{"model":"mistral-small-latest","options":{"maxTokens":2048,"temperature":0.7}},"id":"1668e2c3-0095-4fbb-877e-e60722e8d24b","name":"Mistral Cloud Chat Model","type":"@n8n/n8n-nodes-langchain.lmChatMistralCloud","typeVersion":1,"position":[-208,304],"credentials":{"mistralCloudApi":{"id":"b9hl3JA2taufCYVr","name":"Mistral API"}}},{"parameters":{"sessionIdType":"customKey","sessionKey":"={{ $('Verify JWT').first().json.sessionId }}","contextWindowLength":10},"id":"cffc5919-5412-4308-9671-843b8d2d035f","name":"Postgres Chat Memory","type":"@n8n/n8n-nodes-langchain.memoryPostgresChat","typeVersion":1.3,"position":[0,304],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"jsCode":"const agentResponse = $input.first().json.output;\\nconst jwtData = $('Prepare Quota').first().json;\\n\\n// Estimation tokens (environ 4 chars par token)\\nconst messageTokens = Math.ceil(jwtData.message.length / 4);\\nconst responseTokens = Math.ceil(agentResponse.length / 4);\\nconst tokensUsed = messageTokens + responseTokens;\\n\\nconst newUsedTokens = jwtData.usedTokens + tokensUsed;\\nconst tokensRemaining = jwtData.quotaTokens - newUsedTokens;\\n\\nreturn [{\\n  json: {\\n    userId: jwtData.userId,\\n    conversationId: jwtData.conversationId,\\n    message: jwtData.message,\\n    response: agentResponse,\\n    tokensUsed,\\n    newUsedTokens,\\n    tokensRemaining: Math.max(0, tokensRemaining),\\n    quotaTokens: jwtData.quotaTokens\\n  }\\n}];"},"id":"b2c9d072-5736-4839-9f3f-8c63b5fe8801","name":"Prepare Save","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"operation":"executeQuery","query":"INSERT INTO conversations (conversation_id, user_id, title, created_at, updated_at)\\nVALUES (\\n  '{{ $json.conversationId }}'::uuid,\\n  {{ $json.userId }},\\n  '{{ $json.message.substring(0, 50).replace(/'/g, \\"''\\") }}',\\n  NOW(),\\n  NOW()\\n)\\nON CONFLICT (conversation_id)\\nDO UPDATE SET updated_at = NOW();","options":{}},"id":"6c1ace5b-ec88-44b5-a9b5-182a4957e5c9","name":"UPSERT Conversation","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[448,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"operation":"executeQuery","query":"INSERT INTO messages (conversation_id, user_id, role, content, tokens, created_at)\\nVALUES (\\n  '{{ $('Prepare Save').first().json.conversationId }}'::uuid,\\n  {{ $('Prepare Save').first().json.userId }},\\n  'user',\\n  '{{ $('Prepare Save').first().json.message.replace(/'/g, \\"''\\").replace(/\\\\\\\\/g, '\\\\\\\\\\\\\\\\') }}',\\n  {{ Math.ceil($('Prepare Save').first().json.message.length / 4) }},\\n  NOW()\\n);","options":{}},"id":"19bf528f-0b9d-44d5-b768-58e63ddee026","name":"INSERT User Message","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[672,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"operation":"executeQuery","query":"INSERT INTO messages (conversation_id, user_id, role, content, tokens, created_at)\\nVALUES (\\n  '{{ $('Prepare Save').first().json.conversationId }}'::uuid,\\n  {{ $('Prepare Save').first().json.userId }},\\n  'assistant',\\n  '{{ $('Prepare Save').first().json.response.replace(/'/g, \\"''\\").replace(/\\\\\\\\/g, '\\\\\\\\\\\\\\\\') }}',\\n  {{ Math.ceil($('Prepare Save').first().json.response.length / 4) }},\\n  NOW()\\n);","options":{}},"id":"22a33991-a55c-428d-b673-3b0eef3b8a1a","name":"INSERT Assistant Message","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[880,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"operation":"executeQuery","query":"INSERT INTO user_token_usage (user_id, month, used_tokens, quota_tokens)\\nVALUES (\\n  {{ $('Prepare Save').first().json.userId }},\\n  DATE_TRUNC('month', CURRENT_DATE),\\n  {{ $('Prepare Save').first().json.tokensUsed }},\\n  50000\\n)\\nON CONFLICT (user_id, month)\\nDO UPDATE SET used_tokens = user_token_usage.used_tokens + {{ $('Prepare Save').first().json.tokensUsed }};","options":{}},"id":"344a1edc-fdf7-4ba0-a506-10b00624a0ac","name":"UPDATE Token Usage","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[1104,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"jsCode":"const data = $('Prepare Save').first().json;\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    response: data.response,\\n    tokens_used: data.tokensUsed,\\n    tokens_remaining: data.tokensRemaining,\\n    conversation_id: data.conversationId\\n  }\\n}];"},"id":"d3257586-4db1-4ccf-8b88-2ec7203c06ee","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1328,0]},{"parameters":{"respondWith":"json","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"bfca5f39-23d9-494d-9b4e-767225255749","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1552,0]}]	{"Webhook Chat":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Check Quota","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Check Quota":{"main":[[{"node":"Prepare Quota","type":"main","index":0}]]},"Prepare Quota":{"main":[[{"node":"Quota OK?","type":"main","index":0}]]},"Quota OK?":{"main":[[{"node":"AI Agent","type":"main","index":0}],[{"node":"Quota Exceeded","type":"main","index":0}]]},"Mistral Cloud Chat Model":{"ai_languageModel":[[{"node":"AI Agent","type":"ai_languageModel","index":0}]]},"Postgres Chat Memory":{"ai_memory":[[{"node":"AI Agent","type":"ai_memory","index":0}]]},"AI Agent":{"main":[[{"node":"Prepare Save","type":"main","index":0}]]},"Prepare Save":{"main":[[{"node":"UPSERT Conversation","type":"main","index":0}]]},"UPSERT Conversation":{"main":[[{"node":"INSERT User Message","type":"main","index":0}]]},"INSERT User Message":{"main":[[{"node":"INSERT Assistant Message","type":"main","index":0}]]},"INSERT Assistant Message":{"main":[[{"node":"UPDATE Token Usage","type":"main","index":0}]]},"UPDATE Token Usage":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}}	2025-12-26 17:23:30.579+00	2025-12-26 17:24:09.477+00	{"executionOrder":"v1"}	\N	{}	7924c06c-c403-4b11-a377-81bbcf664b88	1	NynEDh5rxUQL7788	{"templateCredsSetupCompleted":true}	\N	f	12	\N	7924c06c-c403-4b11-a377-81bbcf664b88
WIBOT - Create Conversation	t	[{"parameters":{"httpMethod":"POST","path":"wibot/conversations","responseMode":"responseNode","options":{}},"id":"af7c1cc8-dfdd-42a7-a19a-1c60907e9ae6","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-656,112],"webhookId":"wibot-create-conversation"},{"parameters":{"jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst body = $input.first().json.body || {};\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  // Générer un ID unique simple\\n  const conversationId = Date.now().toString(36) + Math.random().toString(36).substring(2, 9);\\n  const title = body.title || 'Nouvelle conversation';\\n  \\n  return [{ json: { valid: true, userId: decoded.userId, conversationId, title } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}"},"id":"5929e675-2d1f-48e5-97e6-8e4693d7bdd9","name":"Verify JWT & Generate ID","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"845f91c7-8b3c-4430-93ae-b37ab64c224b","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"respondWith":"json","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"870e67eb-07cc-45e3-9d9b-ba9d10763be2","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"jsCode":"const data = $input.first().json;\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    conversation: {\\n      conversation_id: data.conversationId,\\n      title: data.title,\\n      updated_at: new Date().toISOString(),\\n      message_count: 0\\n    }\\n  }\\n}];"},"id":"c51dc0f7-51a7-40cc-b4eb-7b6376bfc052","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[0,0]},{"parameters":{"respondWith":"json","responseBody":"={{ $json }}","options":{"responseCode":201,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"d064af03-7d82-4dcb-b021-807eeaa5068d","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[224,0]}]	{"Webhook":{"main":[[{"node":"Verify JWT & Generate ID","type":"main","index":0}]]},"Verify JWT & Generate ID":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Format Response","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}}	2025-12-26 17:23:38.667+00	2025-12-26 17:24:08.657+00	{"executionOrder":"v1"}	\N	{}	ddcdc8a7-a9db-4f8f-b28f-ec23b55fa640	1	oJ8RPfYOe0ed1LSJ	\N	\N	f	12	\N	ddcdc8a7-a9db-4f8f-b28f-ec23b55fa640
\.


--
-- Data for Name: workflow_history; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.workflow_history ("versionId", "workflowId", authors, "createdAt", "updatedAt", nodes, connections, name, autosaved, description) FROM stdin;
1e31f7d7-5e68-47eb-863c-91d1ec7b0819	zZSHB9BHjR30ThPP	Maxime Ripouteau	2025-12-26 17:23:18.804+00	2025-12-26 17:23:18.804+00	[{"parameters":{"httpMethod":"POST","path":"auth/login","responseMode":"responseNode","options":{}},"id":"c8898033-10a2-436a-915d-a01f108756c6","name":"Webhook Login","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-1104,208],"webhookId":"auth-login"},{"parameters":{"operation":"select","schema":"public","table":"users","limit":1,"where":{"values":[{"column":"username","value":"={{ $json.body.username }}"},{"column":"is_active","value":"true"}]},"options":{}},"id":"a2a158de-b676-468b-a23e-18466966d674","name":"Get User","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[-880,208],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-user-exists","leftValue":"={{ $json.user_id }}","rightValue":"","operator":{"type":"exists","operation":"exists"}}],"combinator":"and"},"options":{}},"id":"dd3f022d-09ed-47fe-ba59-73ae33165762","name":"User Exists?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-656,208]},{"parameters":{"jsCode":"const inputPassword = $('Webhook Login').first().json.body.password;\\nconst storedHash = $input.first().json.password_hash;\\nconst user = $input.first().json;\\n\\n// Comparaison simple du mot de passe\\nconst isValid = (inputPassword === storedHash);\\n\\nreturn [{ json: { isValid, user } }];"},"id":"bb41f913-1c3c-4afb-88a4-c46324c2b9ec","name":"Verify Password","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-password-valid","leftValue":"={{ $json.isValid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"73c0896e-95a9-4677-86c9-3398d7856fad","name":"Password Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"jsCode":"const user = $input.first().json.user;\\n\\n// Fonction base64 encode compatible n8n\\nfunction toBase64(str) {\\n  return Buffer.from(str).toString('base64').replace(/=/g, '').replace(/\\\\+/g, '-').replace(/\\\\//g, '_');\\n}\\n\\nconst header = toBase64(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));\\n\\nconst payload = toBase64(JSON.stringify({\\n  userId: user.user_id,\\n  username: user.username,\\n  role: user.role,\\n  iat: Math.floor(Date.now() / 1000),\\n  exp: Math.floor(Date.now() / 1000) + (24 * 60 * 60)\\n}));\\n\\n// Signature simplifiée\\nconst signature = toBase64(header + payload + 'wibot_secret').substring(0, 43);\\n\\nconst token = `${header}.${payload}.${signature}`;\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    token,\\n    user: {\\n      id: user.user_id,\\n      username: user.username,\\n      role: user.role\\n    }\\n  }\\n}];"},"id":"56756190-1aeb-4413-946a-e2a7b4907e8e","name":"Generate JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[0,0]},{"parameters":{"respondWith":"json","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"5e5d60cc-5fee-4f26-b838-71d66c7a885a","name":"Success Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[224,0]},{"parameters":{"respondWith":"json","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"Invalid credentials\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"e90d3bbc-527a-4b00-b1dc-9bb17afa5966","name":"Invalid Password","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,208]},{"parameters":{"respondWith":"json","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"User not found\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"8423d2d4-a607-49d0-a6d7-8730cf78fd86","name":"User Not Found","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[-448,304]}]	{"Webhook Login":{"main":[[{"node":"Get User","type":"main","index":0}]]},"Get User":{"main":[[{"node":"User Exists?","type":"main","index":0}]]},"User Exists?":{"main":[[{"node":"Verify Password","type":"main","index":0}],[{"node":"User Not Found","type":"main","index":0}]]},"Verify Password":{"main":[[{"node":"Password Valid?","type":"main","index":0}]]},"Password Valid?":{"main":[[{"node":"Generate JWT","type":"main","index":0}],[{"node":"Invalid Password","type":"main","index":0}]]},"Generate JWT":{"main":[[{"node":"Success Response","type":"main","index":0}]]}}	\N	f	\N
7924c06c-c403-4b11-a377-81bbcf664b88	NynEDh5rxUQL7788	Maxime Ripouteau	2025-12-26 17:23:30.579+00	2025-12-26 17:23:30.579+00	[{"parameters":{"httpMethod":"POST","path":"wibot/chat","responseMode":"responseNode","options":{}},"id":"fa8ec4be-706d-4001-ad6c-fcb0f99736af","name":"Webhook Chat","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-1328,112],"webhookId":"wibot-chat"},{"parameters":{"jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst body = $input.first().json.body;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  // Decode base64url payload\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  // Check expiration\\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ \\n    json: { \\n      valid: true, \\n      user: decoded,\\n      userId: decoded.userId,\\n      conversationId: body.conversation_id,\\n      message: body.message,\\n      sessionId: `${decoded.userId}_${body.conversation_id}`\\n    } \\n  }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}"},"id":"0004c18c-eca3-41dc-997e-590e7fd79356","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-1104,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"bfcef1a4-73b6-486c-aab3-5977d98eb079","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-880,112]},{"parameters":{"respondWith":"json","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"cba8bdb1-b75a-4f70-aa59-b7a0eda05fa5","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[-656,352]},{"parameters":{"operation":"executeQuery","query":"SELECT \\n  COALESCE(used_tokens, 0) as used_tokens,\\n  COALESCE(quota_tokens, 50000) as quota_tokens\\nFROM user_token_usage\\nWHERE user_id = {{ $json.userId }}\\n  AND month = DATE_TRUNC('month', CURRENT_DATE)\\nLIMIT 1;","options":{}},"id":"c95bf25e-6737-45ac-a7bb-499bc0b7c7dc","name":"Check Quota","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[-656,112],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"jsCode":"const rows = $input.all();\\nconst jwtData = $('Verify JWT').first().json;\\n\\nlet usedTokens = 0;\\nlet quotaTokens = 50000;\\n\\nif (rows && rows.length > 0 && rows[0].json.used_tokens !== undefined) {\\n  usedTokens = parseInt(rows[0].json.used_tokens) || 0;\\n  quotaTokens = parseInt(rows[0].json.quota_tokens) || 50000;\\n}\\n\\nconst quotaExceeded = usedTokens >= quotaTokens;\\n\\nreturn [{\\n  json: {\\n    ...jwtData,\\n    usedTokens,\\n    quotaTokens,\\n    quotaExceeded\\n  }\\n}];"},"id":"4a1c034d-d824-4eec-8f7d-30e703f1deb5","name":"Prepare Quota","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-quota-ok","leftValue":"={{ $json.quotaExceeded }}","rightValue":false,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"19cfec26-6daa-4bf5-a4dd-9c46bc7e775a","name":"Quota OK?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"respondWith":"json","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"Quota tokens mensuel depass\\\\u00e9. Limite : 50,000 tokens/mois.\\",\\n  \\"code\\": \\"QUOTA_EXCEEDED\\"\\n}","options":{"responseCode":429,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"664cd109-b947-42ee-b8c1-42b595e37b31","name":"Quota Exceeded","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"promptType":"define","text":"={{ $json.message }}","options":{"systemMessage":"Tu es WIBOT, l'assistant IA interne de WIDIP, une entreprise francaise de services informatiques.\\n\\nTon role:\\n- Aider les employes WIDIP avec leurs questions techniques\\n- Fournir des reponses claires et professionnelles\\n- Utiliser le francais par defaut\\n- Etre concis mais complet\\n\\nStyle:\\n- Utilise le markdown pour formater tes reponses\\n- Mets le code dans des blocs avec le langage specifie\\n- Sois amical mais professionnel"}},"id":"9e04ca0c-5683-4a62-828d-5c057cf62605","name":"AI Agent","type":"@n8n/n8n-nodes-langchain.agent","typeVersion":1.7,"position":[0,0]},{"parameters":{"model":"mistral-small-latest","options":{"maxTokens":2048,"temperature":0.7}},"id":"1668e2c3-0095-4fbb-877e-e60722e8d24b","name":"Mistral Cloud Chat Model","type":"@n8n/n8n-nodes-langchain.lmChatMistralCloud","typeVersion":1,"position":[-208,304],"credentials":{"mistralCloudApi":{"id":"b9hl3JA2taufCYVr","name":"Mistral API"}}},{"parameters":{"sessionIdType":"customKey","sessionKey":"={{ $('Verify JWT').first().json.sessionId }}","contextWindowLength":10},"id":"cffc5919-5412-4308-9671-843b8d2d035f","name":"Postgres Chat Memory","type":"@n8n/n8n-nodes-langchain.memoryPostgresChat","typeVersion":1.3,"position":[0,304],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"jsCode":"const agentResponse = $input.first().json.output;\\nconst jwtData = $('Prepare Quota').first().json;\\n\\n// Estimation tokens (environ 4 chars par token)\\nconst messageTokens = Math.ceil(jwtData.message.length / 4);\\nconst responseTokens = Math.ceil(agentResponse.length / 4);\\nconst tokensUsed = messageTokens + responseTokens;\\n\\nconst newUsedTokens = jwtData.usedTokens + tokensUsed;\\nconst tokensRemaining = jwtData.quotaTokens - newUsedTokens;\\n\\nreturn [{\\n  json: {\\n    userId: jwtData.userId,\\n    conversationId: jwtData.conversationId,\\n    message: jwtData.message,\\n    response: agentResponse,\\n    tokensUsed,\\n    newUsedTokens,\\n    tokensRemaining: Math.max(0, tokensRemaining),\\n    quotaTokens: jwtData.quotaTokens\\n  }\\n}];"},"id":"b2c9d072-5736-4839-9f3f-8c63b5fe8801","name":"Prepare Save","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"operation":"executeQuery","query":"INSERT INTO conversations (conversation_id, user_id, title, created_at, updated_at)\\nVALUES (\\n  '{{ $json.conversationId }}'::uuid,\\n  {{ $json.userId }},\\n  '{{ $json.message.substring(0, 50).replace(/'/g, \\"''\\") }}',\\n  NOW(),\\n  NOW()\\n)\\nON CONFLICT (conversation_id)\\nDO UPDATE SET updated_at = NOW();","options":{}},"id":"6c1ace5b-ec88-44b5-a9b5-182a4957e5c9","name":"UPSERT Conversation","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[448,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"operation":"executeQuery","query":"INSERT INTO messages (conversation_id, user_id, role, content, tokens, created_at)\\nVALUES (\\n  '{{ $('Prepare Save').first().json.conversationId }}'::uuid,\\n  {{ $('Prepare Save').first().json.userId }},\\n  'user',\\n  '{{ $('Prepare Save').first().json.message.replace(/'/g, \\"''\\").replace(/\\\\\\\\/g, '\\\\\\\\\\\\\\\\') }}',\\n  {{ Math.ceil($('Prepare Save').first().json.message.length / 4) }},\\n  NOW()\\n);","options":{}},"id":"19bf528f-0b9d-44d5-b768-58e63ddee026","name":"INSERT User Message","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[672,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"operation":"executeQuery","query":"INSERT INTO messages (conversation_id, user_id, role, content, tokens, created_at)\\nVALUES (\\n  '{{ $('Prepare Save').first().json.conversationId }}'::uuid,\\n  {{ $('Prepare Save').first().json.userId }},\\n  'assistant',\\n  '{{ $('Prepare Save').first().json.response.replace(/'/g, \\"''\\").replace(/\\\\\\\\/g, '\\\\\\\\\\\\\\\\') }}',\\n  {{ Math.ceil($('Prepare Save').first().json.response.length / 4) }},\\n  NOW()\\n);","options":{}},"id":"22a33991-a55c-428d-b673-3b0eef3b8a1a","name":"INSERT Assistant Message","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[880,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"operation":"executeQuery","query":"INSERT INTO user_token_usage (user_id, month, used_tokens, quota_tokens)\\nVALUES (\\n  {{ $('Prepare Save').first().json.userId }},\\n  DATE_TRUNC('month', CURRENT_DATE),\\n  {{ $('Prepare Save').first().json.tokensUsed }},\\n  50000\\n)\\nON CONFLICT (user_id, month)\\nDO UPDATE SET used_tokens = user_token_usage.used_tokens + {{ $('Prepare Save').first().json.tokensUsed }};","options":{}},"id":"344a1edc-fdf7-4ba0-a506-10b00624a0ac","name":"UPDATE Token Usage","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[1104,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"jsCode":"const data = $('Prepare Save').first().json;\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    response: data.response,\\n    tokens_used: data.tokensUsed,\\n    tokens_remaining: data.tokensRemaining,\\n    conversation_id: data.conversationId\\n  }\\n}];"},"id":"d3257586-4db1-4ccf-8b88-2ec7203c06ee","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1328,0]},{"parameters":{"respondWith":"json","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"bfca5f39-23d9-494d-9b4e-767225255749","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[1552,0]}]	{"Webhook Chat":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Check Quota","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Check Quota":{"main":[[{"node":"Prepare Quota","type":"main","index":0}]]},"Prepare Quota":{"main":[[{"node":"Quota OK?","type":"main","index":0}]]},"Quota OK?":{"main":[[{"node":"AI Agent","type":"main","index":0}],[{"node":"Quota Exceeded","type":"main","index":0}]]},"Mistral Cloud Chat Model":{"ai_languageModel":[[{"node":"AI Agent","type":"ai_languageModel","index":0}]]},"Postgres Chat Memory":{"ai_memory":[[{"node":"AI Agent","type":"ai_memory","index":0}]]},"AI Agent":{"main":[[{"node":"Prepare Save","type":"main","index":0}]]},"Prepare Save":{"main":[[{"node":"UPSERT Conversation","type":"main","index":0}]]},"UPSERT Conversation":{"main":[[{"node":"INSERT User Message","type":"main","index":0}]]},"INSERT User Message":{"main":[[{"node":"INSERT Assistant Message","type":"main","index":0}]]},"INSERT Assistant Message":{"main":[[{"node":"UPDATE Token Usage","type":"main","index":0}]]},"UPDATE Token Usage":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}}	\N	f	\N
ddcdc8a7-a9db-4f8f-b28f-ec23b55fa640	oJ8RPfYOe0ed1LSJ	Maxime Ripouteau	2025-12-26 17:23:38.667+00	2025-12-26 17:23:38.667+00	[{"parameters":{"httpMethod":"POST","path":"wibot/conversations","responseMode":"responseNode","options":{}},"id":"af7c1cc8-dfdd-42a7-a19a-1c60907e9ae6","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-656,112],"webhookId":"wibot-create-conversation"},{"parameters":{"jsCode":"const authHeader = $input.first().json.headers.authorization;\\nconst body = $input.first().json.body || {};\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  // Générer un ID unique simple\\n  const conversationId = Date.now().toString(36) + Math.random().toString(36).substring(2, 9);\\n  const title = body.title || 'Nouvelle conversation';\\n  \\n  return [{ json: { valid: true, userId: decoded.userId, conversationId, title } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}"},"id":"5929e675-2d1f-48e5-97e6-8e4693d7bdd9","name":"Verify JWT & Generate ID","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"845f91c7-8b3c-4430-93ae-b37ab64c224b","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"respondWith":"json","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"870e67eb-07cc-45e3-9d9b-ba9d10763be2","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"jsCode":"const data = $input.first().json;\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    conversation: {\\n      conversation_id: data.conversationId,\\n      title: data.title,\\n      updated_at: new Date().toISOString(),\\n      message_count: 0\\n    }\\n  }\\n}];"},"id":"c51dc0f7-51a7-40cc-b4eb-7b6376bfc052","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[0,0]},{"parameters":{"respondWith":"json","responseBody":"={{ $json }}","options":{"responseCode":201,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"d064af03-7d82-4dcb-b021-807eeaa5068d","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[224,0]}]	{"Webhook":{"main":[[{"node":"Verify JWT & Generate ID","type":"main","index":0}]]},"Verify JWT & Generate ID":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Format Response","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}}	\N	f	\N
e1bae720-4a31-4afe-a595-4a35f7e26b0f	yPYTzGXVRP2JQxs8	Maxime Ripouteau	2025-12-26 17:23:46.197+00	2025-12-26 17:23:46.197+00	[{"parameters":{"path":"wibot/conversations","responseMode":"responseNode","options":{}},"id":"c0f9fbaf-d0bb-4e86-92e9-c3e34e750679","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-656,112],"webhookId":"wibot-conversations"},{"parameters":{"jsCode":"const authHeader = $input.first().json.headers.authorization;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}"},"id":"a5bd8ac1-82cc-4021-8420-752f46440f49","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"352ea961-e9a7-4651-acad-b594ba9f1c8c","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"respondWith":"json","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"9a0fd5d7-2e41-4111-b2b2-f84c1403ea28","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"operation":"executeQuery","query":"SELECT \\n  c.conversation_id::text,\\n  c.title,\\n  TO_CHAR(c.updated_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as updated_at,\\n  COUNT(m.message_id)::integer as message_count\\nFROM conversations c\\nLEFT JOIN messages m ON c.conversation_id = m.conversation_id\\nWHERE c.user_id = {{ $json.userId }}\\nGROUP BY c.conversation_id, c.title, c.updated_at\\nORDER BY c.updated_at DESC\\nLIMIT 50;","options":{}},"id":"8fe150d4-0f4e-41ac-bd90-8978f31f4459","name":"Get Conversations","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[0,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"jsCode":"const rows = $input.all();\\n\\n// Si pas de resultats ou resultats vides\\nif (!rows || rows.length === 0 || !rows[0].json.conversation_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      conversations: []\\n    }\\n  }];\\n}\\n\\nconst conversations = rows.map(row => ({\\n  conversation_id: row.json.conversation_id,\\n  title: row.json.title || 'Nouvelle conversation',\\n  updated_at: row.json.updated_at,\\n  message_count: parseInt(row.json.message_count) || 0\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    conversations\\n  }\\n}];"},"id":"8d9137c5-9aa8-4938-961f-50bdbc93ee8f","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"respondWith":"json","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"463fcf83-1d8e-472a-94df-623b505f1a5d","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[448,0]}]	{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Conversations","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Conversations":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}}	\N	f	\N
62643582-5e10-4f85-9c6c-74a85d102e67	c8fbjjX9ObuzBE4b	Maxime Ripouteau	2025-12-26 17:24:01.471+00	2025-12-26 17:24:01.471+00	[{"parameters":{"path":"wibot/user/tokens","responseMode":"responseNode","options":{}},"id":"8fcee23f-b3e4-4c28-ad04-4ba456f7752a","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-656,112],"webhookId":"wibot-user-tokens"},{"parameters":{"jsCode":"const authHeader = $input.first().json.headers.authorization;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}"},"id":"d8de2cd5-94e4-49a5-a318-1ee1c389abd9","name":"Verify JWT","type":"n8n-nodes-base.code","typeVersion":2,"position":[-448,112]},{"parameters":{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict"},"conditions":[{"id":"check-jwt-valid","leftValue":"={{ $json.valid }}","rightValue":true,"operator":{"type":"boolean","operation":"equals"}}],"combinator":"and"},"options":{}},"id":"c9c309e4-53ba-46be-8960-13da82f4f5f7","name":"JWT Valid?","type":"n8n-nodes-base.if","typeVersion":2,"position":[-224,112]},{"parameters":{"respondWith":"json","responseBody":"={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}","options":{"responseCode":401,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"83cd3ac8-fb46-4de5-a8ce-5d24be08334c","name":"Unauthorized","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[0,256]},{"parameters":{"operation":"executeQuery","query":"SELECT \\n  COALESCE(used_tokens, 0) as used_tokens,\\n  COALESCE(quota_tokens, 50000) as quota_tokens,\\n  COALESCE(quota_tokens, 50000) - COALESCE(used_tokens, 0) as tokens_remaining\\nFROM user_token_usage\\nWHERE user_id = {{ $json.userId }}\\n  AND month = DATE_TRUNC('month', CURRENT_DATE)\\nLIMIT 1;","options":{}},"id":"b35fa964-24c4-49ed-a3b6-7df917662ceb","name":"Get Token Usage","type":"n8n-nodes-base.postgres","typeVersion":2.5,"position":[0,0],"credentials":{"postgres":{"id":"yY2GzRzLXTG4anFZ","name":"WIBOT PostgreSQL"}}},{"parameters":{"jsCode":"const rows = $input.all();\\nconst jwtData = $('Verify JWT').first().json;\\n\\n// Si pas de donnees, l'utilisateur n'a pas encore utilise de tokens ce mois\\nif (!rows || rows.length === 0 || rows[0].json.tokens_remaining === undefined) {\\n  return [{\\n    json: {\\n      success: true,\\n      used_tokens: 0,\\n      quota_tokens: 50000,\\n      tokens_remaining: 50000\\n    }\\n  }];\\n}\\n\\nconst data = rows[0].json;\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    used_tokens: parseInt(data.used_tokens) || 0,\\n    quota_tokens: parseInt(data.quota_tokens) || 50000,\\n    tokens_remaining: parseInt(data.tokens_remaining) || 50000\\n  }\\n}];"},"id":"7d9b1764-6fed-49d3-957f-402aa7f05696","name":"Format Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[224,0]},{"parameters":{"respondWith":"json","responseBody":"={{ $json }}","options":{"responseCode":200,"responseHeaders":{"entries":[{"name":"Content-Type","value":"application/json"}]}}},"id":"67daad4e-a2fe-4b36-b18c-065181b80de3","name":"Success","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[448,0]}]	{"Webhook":{"main":[[{"node":"Verify JWT","type":"main","index":0}]]},"Verify JWT":{"main":[[{"node":"JWT Valid?","type":"main","index":0}]]},"JWT Valid?":{"main":[[{"node":"Get Token Usage","type":"main","index":0}],[{"node":"Unauthorized","type":"main","index":0}]]},"Get Token Usage":{"main":[[{"node":"Format Response","type":"main","index":0}]]},"Format Response":{"main":[[{"node":"Success","type":"main","index":0}]]}}	\N	f	\N
704bc444-e5e2-4901-9322-383bc1bd0434	msg5c740bd9db51	system	2025-12-26 18:00:27.534+00	2025-12-26 18:00:27.534+00	[{"parameters": {"httpMethod": "GET", "path": "wibot/messages", "responseMode": "responseNode", "options": {}}, "id": "webhook-messages", "name": "Webhook", "type": "n8n-nodes-base.webhook", "typeVersion": 2, "position": [250, 300], "webhookId": "wibot-messages"}, {"parameters": {"jsCode": "const authHeader = $input.first().json.headers.authorization;\\nconst conversationId = $input.first().json.query.conversationId;\\n\\nif (!authHeader || !authHeader.startsWith('Bearer ')) {\\n  return [{ json: { valid: false, error: 'No token provided' } }];\\n}\\n\\nif (!conversationId) {\\n  return [{ json: { valid: false, error: 'conversationId is required' } }];\\n}\\n\\nconst token = authHeader.substring(7);\\nconst parts = token.split('.');\\n\\nif (parts.length !== 3) {\\n  return [{ json: { valid: false, error: 'Invalid token format' } }];\\n}\\n\\ntry {\\n  const payload = parts[1];\\n  const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());\\n  \\n  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) {\\n    return [{ json: { valid: false, error: 'Token expired' } }];\\n  }\\n  \\n  return [{ json: { valid: true, userId: decoded.userId, conversationId } }];\\n} catch (err) {\\n  return [{ json: { valid: false, error: 'Invalid token' } }];\\n}"}, "id": "verify-jwt", "name": "Verify JWT", "type": "n8n-nodes-base.code", "typeVersion": 2, "position": [470, 300]}, {"parameters": {"conditions": {"options": {"caseSensitive": true, "leftValue": "", "typeValidation": "strict"}, "conditions": [{"id": "check-jwt-valid", "leftValue": "={{ $json.valid }}", "rightValue": true, "operator": {"type": "boolean", "operation": "equals"}}], "combinator": "and"}, "options": {}}, "id": "if-jwt-valid", "name": "JWT Valid?", "type": "n8n-nodes-base.if", "typeVersion": 2, "position": [690, 300]}, {"parameters": {"respondWith": "json", "responseBody": "={\\n  \\"success\\": false,\\n  \\"error\\": \\"{{ $json.error }}\\"\\n}", "options": {"responseCode": 401, "responseHeaders": {"entries": [{"name": "Content-Type", "value": "application/json"}]}}}, "id": "respond-unauthorized", "name": "Unauthorized", "type": "n8n-nodes-base.respondToWebhook", "typeVersion": 1.1, "position": [910, 450]}, {"parameters": {"operation": "executeQuery", "query": "SELECT \\n  m.message_id,\\n  m.role,\\n  m.content,\\n  TO_CHAR(m.created_at, 'YYYY-MM-DD\\"T\\"HH24:MI:SS\\"Z\\"') as created_at\\nFROM messages m\\nJOIN conversations c ON m.conversation_id = c.conversation_id\\nWHERE m.conversation_id = '{{ $json.conversationId }}'::uuid\\n  AND c.user_id = {{ $json.userId }}\\nORDER BY m.created_at ASC;", "options": {}}, "id": "get-messages", "name": "Get Messages", "type": "n8n-nodes-base.postgres", "typeVersion": 2.5, "position": [910, 200], "credentials": {"postgres": {"id": "yY2GzRzLXTG4anFZ", "name": "WIBOT PostgreSQL"}}}, {"parameters": {"jsCode": "const rows = $input.all();\\n\\n// Si pas de resultats, retourner liste vide\\nif (!rows || rows.length === 0 || !rows[0].json.message_id) {\\n  return [{\\n    json: {\\n      success: true,\\n      messages: []\\n    }\\n  }];\\n}\\n\\nconst messages = rows.map(row => ({\\n  message_id: row.json.message_id,\\n  role: row.json.role,\\n  content: row.json.content,\\n  created_at: row.json.created_at\\n}));\\n\\nreturn [{\\n  json: {\\n    success: true,\\n    messages\\n  }\\n}];"}, "id": "format-response", "name": "Format Response", "type": "n8n-nodes-base.code", "typeVersion": 2, "position": [1130, 200]}, {"parameters": {"respondWith": "json", "responseBody": "={{ $json }}", "options": {"responseCode": 200, "responseHeaders": {"entries": [{"name": "Content-Type", "value": "application/json"}]}}}, "id": "respond-success", "name": "Success", "type": "n8n-nodes-base.respondToWebhook", "typeVersion": 1.1, "position": [1350, 200]}]	{"Webhook": {"main": [[{"node": "Verify JWT", "type": "main", "index": 0}]]}, "Verify JWT": {"main": [[{"node": "JWT Valid?", "type": "main", "index": 0}]]}, "JWT Valid?": {"main": [[{"node": "Get Messages", "type": "main", "index": 0}], [{"node": "Unauthorized", "type": "main", "index": 0}]]}, "Get Messages": {"main": [[{"node": "Format Response", "type": "main", "index": 0}]]}, "Format Response": {"main": [[{"node": "Success", "type": "main", "index": 0}]]}}	WIBOT - Get Messages	f	\N
\.


--
-- Data for Name: workflow_statistics; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.workflow_statistics (count, "latestEvent", name, "workflowId", "rootCount") FROM stdin;
9	2025-12-26 21:59:08.398+00	production_success	c8fbjjX9ObuzBE4b	9
11	2025-12-26 21:59:08.399+00	production_success	yPYTzGXVRP2JQxs8	11
22	2025-12-26 21:59:12.889+00	production_success	msg5c740bd9db51	22
1	2025-12-26 17:24:52.371+00	data_loaded	zZSHB9BHjR30ThPP	1
1	2025-12-26 17:28:06.627+00	data_loaded	c8fbjjX9ObuzBE4b	1
1	2025-12-26 17:28:06.63+00	data_loaded	yPYTzGXVRP2JQxs8	1
1	2025-12-26 17:28:13.169+00	data_loaded	NynEDh5rxUQL7788	1
1	2025-12-26 18:00:56.354+00	data_loaded	msg5c740bd9db51	1
3	2025-12-26 18:02:55.955+00	production_success	NynEDh5rxUQL7788	3
7	2025-12-26 18:03:36.2+00	production_success	zZSHB9BHjR30ThPP	7
\.


--
-- Data for Name: workflows_tags; Type: TABLE DATA; Schema: public; Owner: widip
--

COPY public.workflows_tags ("workflowId", "tagId") FROM stdin;
zZSHB9BHjR30ThPP	kqzTIvUMe4tyfHJb
NynEDh5rxUQL7788	kqzTIvUMe4tyfHJb
oJ8RPfYOe0ed1LSJ	kqzTIvUMe4tyfHJb
yPYTzGXVRP2JQxs8	kqzTIvUMe4tyfHJb
c8fbjjX9ObuzBE4b	kqzTIvUMe4tyfHJb
\.


--
-- Name: auth_provider_sync_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: widip
--

SELECT pg_catalog.setval('public.auth_provider_sync_history_id_seq', 1, false);


--
-- Name: execution_annotations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: widip
--

SELECT pg_catalog.setval('public.execution_annotations_id_seq', 1, false);


--
-- Name: execution_entity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: widip
--

SELECT pg_catalog.setval('public.execution_entity_id_seq', 125, true);


--
-- Name: execution_metadata_temp_id_seq; Type: SEQUENCE SET; Schema: public; Owner: widip
--

SELECT pg_catalog.setval('public.execution_metadata_temp_id_seq', 1, false);


--
-- Name: insights_by_period_id_seq; Type: SEQUENCE SET; Schema: public; Owner: widip
--

SELECT pg_catalog.setval('public.insights_by_period_id_seq', 54, true);


--
-- Name: insights_metadata_metaId_seq; Type: SEQUENCE SET; Schema: public; Owner: widip
--

SELECT pg_catalog.setval('public."insights_metadata_metaId_seq"', 22, true);


--
-- Name: insights_raw_id_seq; Type: SEQUENCE SET; Schema: public; Owner: widip
--

SELECT pg_catalog.setval('public.insights_raw_id_seq', 250, true);


--
-- Name: messages_message_id_seq; Type: SEQUENCE SET; Schema: public; Owner: widip
--

SELECT pg_catalog.setval('public.messages_message_id_seq', 36, true);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: widip
--

SELECT pg_catalog.setval('public.migrations_id_seq', 120, true);


--
-- Name: n8n_chat_histories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: widip
--

SELECT pg_catalog.setval('public.n8n_chat_histories_id_seq', 74, true);


--
-- Name: oauth_user_consents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: widip
--

SELECT pg_catalog.setval('public.oauth_user_consents_id_seq', 1, false);


--
-- Name: user_token_usage_usage_id_seq; Type: SEQUENCE SET; Schema: public; Owner: widip
--

SELECT pg_catalog.setval('public.user_token_usage_usage_id_seq', 16, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: widip
--

SELECT pg_catalog.setval('public.users_user_id_seq', 2, true);


--
-- Name: workflow_dependency_id_seq; Type: SEQUENCE SET; Schema: public; Owner: widip
--

SELECT pg_catalog.setval('public.workflow_dependency_id_seq', 1, false);


--
-- Name: test_run PK_011c050f566e9db509a0fadb9b9; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.test_run
    ADD CONSTRAINT "PK_011c050f566e9db509a0fadb9b9" PRIMARY KEY (id);


--
-- Name: installed_packages PK_08cc9197c39b028c1e9beca225940576fd1a5804; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.installed_packages
    ADD CONSTRAINT "PK_08cc9197c39b028c1e9beca225940576fd1a5804" PRIMARY KEY ("packageName");


--
-- Name: execution_metadata PK_17a0b6284f8d626aae88e1c16e4; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.execution_metadata
    ADD CONSTRAINT "PK_17a0b6284f8d626aae88e1c16e4" PRIMARY KEY (id);


--
-- Name: project_relation PK_1caaa312a5d7184a003be0f0cb6; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.project_relation
    ADD CONSTRAINT "PK_1caaa312a5d7184a003be0f0cb6" PRIMARY KEY ("projectId", "userId");


--
-- Name: chat_hub_sessions PK_1eafef1273c70e4464fec703412; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.chat_hub_sessions
    ADD CONSTRAINT "PK_1eafef1273c70e4464fec703412" PRIMARY KEY (id);


--
-- Name: folder_tag PK_27e4e00852f6b06a925a4d83a3e; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.folder_tag
    ADD CONSTRAINT "PK_27e4e00852f6b06a925a4d83a3e" PRIMARY KEY ("folderId", "tagId");


--
-- Name: role PK_35c9b140caaf6da09cfabb0d675; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT "PK_35c9b140caaf6da09cfabb0d675" PRIMARY KEY (slug);


--
-- Name: project PK_4d68b1358bb5b766d3e78f32f57; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT "PK_4d68b1358bb5b766d3e78f32f57" PRIMARY KEY (id);


--
-- Name: workflow_dependency PK_52325e34cd7a2f0f67b0f3cad65; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.workflow_dependency
    ADD CONSTRAINT "PK_52325e34cd7a2f0f67b0f3cad65" PRIMARY KEY (id);


--
-- Name: invalid_auth_token PK_5779069b7235b256d91f7af1a15; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.invalid_auth_token
    ADD CONSTRAINT "PK_5779069b7235b256d91f7af1a15" PRIMARY KEY (token);


--
-- Name: shared_workflow PK_5ba87620386b847201c9531c58f; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.shared_workflow
    ADD CONSTRAINT "PK_5ba87620386b847201c9531c58f" PRIMARY KEY ("workflowId", "projectId");


--
-- Name: folder PK_6278a41a706740c94c02e288df8; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.folder
    ADD CONSTRAINT "PK_6278a41a706740c94c02e288df8" PRIMARY KEY (id);


--
-- Name: data_table_column PK_673cb121ee4a8a5e27850c72c51; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.data_table_column
    ADD CONSTRAINT "PK_673cb121ee4a8a5e27850c72c51" PRIMARY KEY (id);


--
-- Name: annotation_tag_entity PK_69dfa041592c30bbc0d4b84aa00; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.annotation_tag_entity
    ADD CONSTRAINT "PK_69dfa041592c30bbc0d4b84aa00" PRIMARY KEY (id);


--
-- Name: oauth_refresh_tokens PK_74abaed0b30711b6532598b0392; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.oauth_refresh_tokens
    ADD CONSTRAINT "PK_74abaed0b30711b6532598b0392" PRIMARY KEY (token);


--
-- Name: chat_hub_messages PK_7704a5add6baed43eef835f0bfb; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.chat_hub_messages
    ADD CONSTRAINT "PK_7704a5add6baed43eef835f0bfb" PRIMARY KEY (id);


--
-- Name: execution_annotations PK_7afcf93ffa20c4252869a7c6a23; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.execution_annotations
    ADD CONSTRAINT "PK_7afcf93ffa20c4252869a7c6a23" PRIMARY KEY (id);


--
-- Name: oauth_user_consents PK_85b9ada746802c8993103470f05; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.oauth_user_consents
    ADD CONSTRAINT "PK_85b9ada746802c8993103470f05" PRIMARY KEY (id);


--
-- Name: migrations PK_8c82d7f526340ab734260ea46be; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT "PK_8c82d7f526340ab734260ea46be" PRIMARY KEY (id);


--
-- Name: installed_nodes PK_8ebd28194e4f792f96b5933423fc439df97d9689; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.installed_nodes
    ADD CONSTRAINT "PK_8ebd28194e4f792f96b5933423fc439df97d9689" PRIMARY KEY (name);


--
-- Name: shared_credentials PK_8ef3a59796a228913f251779cff; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.shared_credentials
    ADD CONSTRAINT "PK_8ef3a59796a228913f251779cff" PRIMARY KEY ("credentialsId", "projectId");


--
-- Name: test_case_execution PK_90c121f77a78a6580e94b794bce; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.test_case_execution
    ADD CONSTRAINT "PK_90c121f77a78a6580e94b794bce" PRIMARY KEY (id);


--
-- Name: user_api_keys PK_978fa5caa3468f463dac9d92e69; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.user_api_keys
    ADD CONSTRAINT "PK_978fa5caa3468f463dac9d92e69" PRIMARY KEY (id);


--
-- Name: execution_annotation_tags PK_979ec03d31294cca484be65d11f; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.execution_annotation_tags
    ADD CONSTRAINT "PK_979ec03d31294cca484be65d11f" PRIMARY KEY ("annotationId", "tagId");


--
-- Name: webhook_entity PK_b21ace2e13596ccd87dc9bf4ea6; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.webhook_entity
    ADD CONSTRAINT "PK_b21ace2e13596ccd87dc9bf4ea6" PRIMARY KEY ("webhookPath", method);


--
-- Name: insights_by_period PK_b606942249b90cc39b0265f0575; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.insights_by_period
    ADD CONSTRAINT "PK_b606942249b90cc39b0265f0575" PRIMARY KEY (id);


--
-- Name: workflow_history PK_b6572dd6173e4cd06fe79937b58; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.workflow_history
    ADD CONSTRAINT "PK_b6572dd6173e4cd06fe79937b58" PRIMARY KEY ("versionId");


--
-- Name: scope PK_bfc45df0481abd7f355d6187da1; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.scope
    ADD CONSTRAINT "PK_bfc45df0481abd7f355d6187da1" PRIMARY KEY (slug);


--
-- Name: oauth_clients PK_c4759172d3431bae6f04e678e0d; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.oauth_clients
    ADD CONSTRAINT "PK_c4759172d3431bae6f04e678e0d" PRIMARY KEY (id);


--
-- Name: processed_data PK_ca04b9d8dc72de268fe07a65773; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.processed_data
    ADD CONSTRAINT "PK_ca04b9d8dc72de268fe07a65773" PRIMARY KEY ("workflowId", context);


--
-- Name: settings PK_dc0fe14e6d9943f268e7b119f69ab8bd; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT "PK_dc0fe14e6d9943f268e7b119f69ab8bd" PRIMARY KEY (key);


--
-- Name: oauth_access_tokens PK_dcd71f96a5d5f4bf79e67d322bf; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT "PK_dcd71f96a5d5f4bf79e67d322bf" PRIMARY KEY (token);


--
-- Name: data_table PK_e226d0001b9e6097cbfe70617cb; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.data_table
    ADD CONSTRAINT "PK_e226d0001b9e6097cbfe70617cb" PRIMARY KEY (id);


--
-- Name: user PK_ea8f538c94b6e352418254ed6474a81f; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT "PK_ea8f538c94b6e352418254ed6474a81f" PRIMARY KEY (id);


--
-- Name: insights_raw PK_ec15125755151e3a7e00e00014f; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.insights_raw
    ADD CONSTRAINT "PK_ec15125755151e3a7e00e00014f" PRIMARY KEY (id);


--
-- Name: chat_hub_agents PK_f39a3b36bbdf0e2979ddb21cf78; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.chat_hub_agents
    ADD CONSTRAINT "PK_f39a3b36bbdf0e2979ddb21cf78" PRIMARY KEY (id);


--
-- Name: insights_metadata PK_f448a94c35218b6208ce20cf5a1; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.insights_metadata
    ADD CONSTRAINT "PK_f448a94c35218b6208ce20cf5a1" PRIMARY KEY ("metaId");


--
-- Name: oauth_authorization_codes PK_fb91ab932cfbd694061501cc20f; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.oauth_authorization_codes
    ADD CONSTRAINT "PK_fb91ab932cfbd694061501cc20f" PRIMARY KEY (code);


--
-- Name: binary_data PK_fc3691585b39408bb0551122af6; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.binary_data
    ADD CONSTRAINT "PK_fc3691585b39408bb0551122af6" PRIMARY KEY ("fileId");


--
-- Name: role_scope PK_role_scope; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.role_scope
    ADD CONSTRAINT "PK_role_scope" PRIMARY KEY ("roleSlug", "scopeSlug");


--
-- Name: oauth_user_consents UQ_083721d99ce8db4033e2958ebb4; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.oauth_user_consents
    ADD CONSTRAINT "UQ_083721d99ce8db4033e2958ebb4" UNIQUE ("userId", "clientId");


--
-- Name: data_table_column UQ_8082ec4890f892f0bc77473a123; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.data_table_column
    ADD CONSTRAINT "UQ_8082ec4890f892f0bc77473a123" UNIQUE ("dataTableId", name);


--
-- Name: data_table UQ_b23096ef747281ac944d28e8b0d; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.data_table
    ADD CONSTRAINT "UQ_b23096ef747281ac944d28e8b0d" UNIQUE ("projectId", name);


--
-- Name: user UQ_e12875dfb3b1d92d7d7c5377e2; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT "UQ_e12875dfb3b1d92d7d7c5377e2" UNIQUE (email);


--
-- Name: auth_identity auth_identity_pkey; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.auth_identity
    ADD CONSTRAINT auth_identity_pkey PRIMARY KEY ("providerId", "providerType");


--
-- Name: auth_provider_sync_history auth_provider_sync_history_pkey; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.auth_provider_sync_history
    ADD CONSTRAINT auth_provider_sync_history_pkey PRIMARY KEY (id);


--
-- Name: conversations conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_pkey PRIMARY KEY (conversation_id);


--
-- Name: credentials_entity credentials_entity_pkey; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.credentials_entity
    ADD CONSTRAINT credentials_entity_pkey PRIMARY KEY (id);


--
-- Name: event_destinations event_destinations_pkey; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.event_destinations
    ADD CONSTRAINT event_destinations_pkey PRIMARY KEY (id);


--
-- Name: execution_data execution_data_pkey; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.execution_data
    ADD CONSTRAINT execution_data_pkey PRIMARY KEY ("executionId");


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (message_id);


--
-- Name: n8n_chat_histories n8n_chat_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.n8n_chat_histories
    ADD CONSTRAINT n8n_chat_histories_pkey PRIMARY KEY (id);


--
-- Name: execution_entity pk_e3e63bbf986767844bbe1166d4e; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.execution_entity
    ADD CONSTRAINT pk_e3e63bbf986767844bbe1166d4e PRIMARY KEY (id);


--
-- Name: workflow_statistics pk_workflow_statistics; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.workflow_statistics
    ADD CONSTRAINT pk_workflow_statistics PRIMARY KEY ("workflowId", name);


--
-- Name: workflows_tags pk_workflows_tags; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.workflows_tags
    ADD CONSTRAINT pk_workflows_tags PRIMARY KEY ("workflowId", "tagId");


--
-- Name: tag_entity tag_entity_pkey; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.tag_entity
    ADD CONSTRAINT tag_entity_pkey PRIMARY KEY (id);


--
-- Name: user_token_usage user_token_usage_pkey; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.user_token_usage
    ADD CONSTRAINT user_token_usage_pkey PRIMARY KEY (usage_id);


--
-- Name: user_token_usage user_token_usage_user_id_month_key; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.user_token_usage
    ADD CONSTRAINT user_token_usage_user_id_month_key UNIQUE (user_id, month);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: variables variables_pkey; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.variables
    ADD CONSTRAINT variables_pkey PRIMARY KEY (id);


--
-- Name: workflow_entity workflow_entity_pkey; Type: CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.workflow_entity
    ADD CONSTRAINT workflow_entity_pkey PRIMARY KEY (id);


--
-- Name: IDX_14f68deffaf858465715995508; Type: INDEX; Schema: public; Owner: widip
--

CREATE UNIQUE INDEX "IDX_14f68deffaf858465715995508" ON public.folder USING btree ("projectId", id);


--
-- Name: IDX_1d8ab99d5861c9388d2dc1cf73; Type: INDEX; Schema: public; Owner: widip
--

CREATE UNIQUE INDEX "IDX_1d8ab99d5861c9388d2dc1cf73" ON public.insights_metadata USING btree ("workflowId");


--
-- Name: IDX_1e31657f5fe46816c34be7c1b4; Type: INDEX; Schema: public; Owner: widip
--

CREATE INDEX "IDX_1e31657f5fe46816c34be7c1b4" ON public.workflow_history USING btree ("workflowId");


--
-- Name: IDX_1ef35bac35d20bdae979d917a3; Type: INDEX; Schema: public; Owner: widip
--

CREATE UNIQUE INDEX "IDX_1ef35bac35d20bdae979d917a3" ON public.user_api_keys USING btree ("apiKey");


--
-- Name: IDX_56900edc3cfd16612e2ef2c6a8; Type: INDEX; Schema: public; Owner: widip
--

CREATE INDEX "IDX_56900edc3cfd16612e2ef2c6a8" ON public.binary_data USING btree ("sourceType", "sourceId");


--
-- Name: IDX_5f0643f6717905a05164090dde; Type: INDEX; Schema: public; Owner: widip
--

CREATE INDEX "IDX_5f0643f6717905a05164090dde" ON public.project_relation USING btree ("userId");


--
-- Name: IDX_60b6a84299eeb3f671dfec7693; Type: INDEX; Schema: public; Owner: widip
--

CREATE UNIQUE INDEX "IDX_60b6a84299eeb3f671dfec7693" ON public.insights_by_period USING btree ("periodStart", type, "periodUnit", "metaId");


--
-- Name: IDX_61448d56d61802b5dfde5cdb00; Type: INDEX; Schema: public; Owner: widip
--

CREATE INDEX "IDX_61448d56d61802b5dfde5cdb00" ON public.project_relation USING btree ("projectId");


--
-- Name: IDX_63d7bbae72c767cf162d459fcc; Type: INDEX; Schema: public; Owner: widip
--

CREATE UNIQUE INDEX "IDX_63d7bbae72c767cf162d459fcc" ON public.user_api_keys USING btree ("userId", label);


--
-- Name: IDX_8e4b4774db42f1e6dda3452b2a; Type: INDEX; Schema: public; Owner: widip
--

CREATE INDEX "IDX_8e4b4774db42f1e6dda3452b2a" ON public.test_case_execution USING btree ("testRunId");


--
-- Name: IDX_97f863fa83c4786f1956508496; Type: INDEX; Schema: public; Owner: widip
--

CREATE UNIQUE INDEX "IDX_97f863fa83c4786f1956508496" ON public.execution_annotations USING btree ("executionId");


--
-- Name: IDX_UniqueRoleDisplayName; Type: INDEX; Schema: public; Owner: widip
--

CREATE UNIQUE INDEX "IDX_UniqueRoleDisplayName" ON public.role USING btree ("displayName");


--
-- Name: IDX_a3697779b366e131b2bbdae297; Type: INDEX; Schema: public; Owner: widip
--

CREATE INDEX "IDX_a3697779b366e131b2bbdae297" ON public.execution_annotation_tags USING btree ("tagId");


--
-- Name: IDX_a4ff2d9b9628ea988fa9e7d0bf; Type: INDEX; Schema: public; Owner: widip
--

CREATE INDEX "IDX_a4ff2d9b9628ea988fa9e7d0bf" ON public.workflow_dependency USING btree ("workflowId");


--
-- Name: IDX_ae51b54c4bb430cf92f48b623f; Type: INDEX; Schema: public; Owner: widip
--

CREATE UNIQUE INDEX "IDX_ae51b54c4bb430cf92f48b623f" ON public.annotation_tag_entity USING btree (name);


--
-- Name: IDX_c1519757391996eb06064f0e7c; Type: INDEX; Schema: public; Owner: widip
--

CREATE INDEX "IDX_c1519757391996eb06064f0e7c" ON public.execution_annotation_tags USING btree ("annotationId");


--
-- Name: IDX_cec8eea3bf49551482ccb4933e; Type: INDEX; Schema: public; Owner: widip
--

CREATE UNIQUE INDEX "IDX_cec8eea3bf49551482ccb4933e" ON public.execution_metadata USING btree ("executionId", key);


--
-- Name: IDX_d6870d3b6e4c185d33926f423c; Type: INDEX; Schema: public; Owner: widip
--

CREATE INDEX "IDX_d6870d3b6e4c185d33926f423c" ON public.test_run USING btree ("workflowId");


--
-- Name: IDX_e48a201071ab85d9d09119d640; Type: INDEX; Schema: public; Owner: widip
--

CREATE INDEX "IDX_e48a201071ab85d9d09119d640" ON public.workflow_dependency USING btree ("dependencyKey");


--
-- Name: IDX_e7fe1cfda990c14a445937d0b9; Type: INDEX; Schema: public; Owner: widip
--

CREATE INDEX "IDX_e7fe1cfda990c14a445937d0b9" ON public.workflow_dependency USING btree ("dependencyType");


--
-- Name: IDX_execution_entity_deletedAt; Type: INDEX; Schema: public; Owner: widip
--

CREATE INDEX "IDX_execution_entity_deletedAt" ON public.execution_entity USING btree ("deletedAt");


--
-- Name: IDX_role_scope_scopeSlug; Type: INDEX; Schema: public; Owner: widip
--

CREATE INDEX "IDX_role_scope_scopeSlug" ON public.role_scope USING btree ("scopeSlug");


--
-- Name: IDX_workflow_entity_name; Type: INDEX; Schema: public; Owner: widip
--

CREATE INDEX "IDX_workflow_entity_name" ON public.workflow_entity USING btree (name);


--
-- Name: idx_07fde106c0b471d8cc80a64fc8; Type: INDEX; Schema: public; Owner: widip
--

CREATE INDEX idx_07fde106c0b471d8cc80a64fc8 ON public.credentials_entity USING btree (type);


--
-- Name: idx_16f4436789e804e3e1c9eeb240; Type: INDEX; Schema: public; Owner: widip
--

CREATE INDEX idx_16f4436789e804e3e1c9eeb240 ON public.webhook_entity USING btree ("webhookId", method, "pathLength");


--
-- Name: idx_812eb05f7451ca757fb98444ce; Type: INDEX; Schema: public; Owner: widip
--

CREATE UNIQUE INDEX idx_812eb05f7451ca757fb98444ce ON public.tag_entity USING btree (name);


--
-- Name: idx_conversations_user; Type: INDEX; Schema: public; Owner: widip
--

CREATE INDEX idx_conversations_user ON public.conversations USING btree (user_id, updated_at DESC);


--
-- Name: idx_execution_entity_stopped_at_status_deleted_at; Type: INDEX; Schema: public; Owner: widip
--

CREATE INDEX idx_execution_entity_stopped_at_status_deleted_at ON public.execution_entity USING btree ("stoppedAt", status, "deletedAt") WHERE (("stoppedAt" IS NOT NULL) AND ("deletedAt" IS NULL));


--
-- Name: idx_execution_entity_wait_till_status_deleted_at; Type: INDEX; Schema: public; Owner: widip
--

CREATE INDEX idx_execution_entity_wait_till_status_deleted_at ON public.execution_entity USING btree ("waitTill", status, "deletedAt") WHERE (("waitTill" IS NOT NULL) AND ("deletedAt" IS NULL));


--
-- Name: idx_execution_entity_workflow_id_started_at; Type: INDEX; Schema: public; Owner: widip
--

CREATE INDEX idx_execution_entity_workflow_id_started_at ON public.execution_entity USING btree ("workflowId", "startedAt") WHERE (("startedAt" IS NOT NULL) AND ("deletedAt" IS NULL));


--
-- Name: idx_messages_conversation; Type: INDEX; Schema: public; Owner: widip
--

CREATE INDEX idx_messages_conversation ON public.messages USING btree (conversation_id, created_at);


--
-- Name: idx_messages_user; Type: INDEX; Schema: public; Owner: widip
--

CREATE INDEX idx_messages_user ON public.messages USING btree (user_id);


--
-- Name: idx_token_usage_user_month; Type: INDEX; Schema: public; Owner: widip
--

CREATE INDEX idx_token_usage_user_month ON public.user_token_usage USING btree (user_id, month);


--
-- Name: idx_workflows_tags_workflow_id; Type: INDEX; Schema: public; Owner: widip
--

CREATE INDEX idx_workflows_tags_workflow_id ON public.workflows_tags USING btree ("workflowId");


--
-- Name: pk_credentials_entity_id; Type: INDEX; Schema: public; Owner: widip
--

CREATE UNIQUE INDEX pk_credentials_entity_id ON public.credentials_entity USING btree (id);


--
-- Name: pk_tag_entity_id; Type: INDEX; Schema: public; Owner: widip
--

CREATE UNIQUE INDEX pk_tag_entity_id ON public.tag_entity USING btree (id);


--
-- Name: pk_workflow_entity_id; Type: INDEX; Schema: public; Owner: widip
--

CREATE UNIQUE INDEX pk_workflow_entity_id ON public.workflow_entity USING btree (id);


--
-- Name: project_relation_role_idx; Type: INDEX; Schema: public; Owner: widip
--

CREATE INDEX project_relation_role_idx ON public.project_relation USING btree (role);


--
-- Name: project_relation_role_project_idx; Type: INDEX; Schema: public; Owner: widip
--

CREATE INDEX project_relation_role_project_idx ON public.project_relation USING btree ("projectId", role);


--
-- Name: user_role_idx; Type: INDEX; Schema: public; Owner: widip
--

CREATE INDEX user_role_idx ON public."user" USING btree ("roleSlug");


--
-- Name: variables_global_key_unique; Type: INDEX; Schema: public; Owner: widip
--

CREATE UNIQUE INDEX variables_global_key_unique ON public.variables USING btree (key) WHERE ("projectId" IS NULL);


--
-- Name: variables_project_key_unique; Type: INDEX; Schema: public; Owner: widip
--

CREATE UNIQUE INDEX variables_project_key_unique ON public.variables USING btree ("projectId", key) WHERE ("projectId" IS NOT NULL);


--
-- Name: conversations update_conversation_timestamp; Type: TRIGGER; Schema: public; Owner: widip
--

CREATE TRIGGER update_conversation_timestamp BEFORE UPDATE ON public.conversations FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: workflow_entity workflow_version_increment; Type: TRIGGER; Schema: public; Owner: widip
--

CREATE TRIGGER workflow_version_increment BEFORE UPDATE ON public.workflow_entity FOR EACH ROW EXECUTE FUNCTION public.increment_workflow_version();


--
-- Name: processed_data FK_06a69a7032c97a763c2c7599464; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.processed_data
    ADD CONSTRAINT "FK_06a69a7032c97a763c2c7599464" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: workflow_entity FK_08d6c67b7f722b0039d9d5ed620; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.workflow_entity
    ADD CONSTRAINT "FK_08d6c67b7f722b0039d9d5ed620" FOREIGN KEY ("activeVersionId") REFERENCES public.workflow_history("versionId") ON DELETE RESTRICT;


--
-- Name: insights_metadata FK_1d8ab99d5861c9388d2dc1cf733; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.insights_metadata
    ADD CONSTRAINT "FK_1d8ab99d5861c9388d2dc1cf733" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE SET NULL;


--
-- Name: workflow_history FK_1e31657f5fe46816c34be7c1b4b; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.workflow_history
    ADD CONSTRAINT "FK_1e31657f5fe46816c34be7c1b4b" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: chat_hub_messages FK_1f4998c8a7dec9e00a9ab15550e; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.chat_hub_messages
    ADD CONSTRAINT "FK_1f4998c8a7dec9e00a9ab15550e" FOREIGN KEY ("revisionOfMessageId") REFERENCES public.chat_hub_messages(id) ON DELETE CASCADE;


--
-- Name: oauth_user_consents FK_21e6c3c2d78a097478fae6aaefa; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.oauth_user_consents
    ADD CONSTRAINT "FK_21e6c3c2d78a097478fae6aaefa" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: insights_metadata FK_2375a1eda085adb16b24615b69c; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.insights_metadata
    ADD CONSTRAINT "FK_2375a1eda085adb16b24615b69c" FOREIGN KEY ("projectId") REFERENCES public.project(id) ON DELETE SET NULL;


--
-- Name: chat_hub_messages FK_25c9736e7f769f3a005eef4b372; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.chat_hub_messages
    ADD CONSTRAINT "FK_25c9736e7f769f3a005eef4b372" FOREIGN KEY ("retryOfMessageId") REFERENCES public.chat_hub_messages(id) ON DELETE CASCADE;


--
-- Name: execution_metadata FK_31d0b4c93fb85ced26f6005cda3; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.execution_metadata
    ADD CONSTRAINT "FK_31d0b4c93fb85ced26f6005cda3" FOREIGN KEY ("executionId") REFERENCES public.execution_entity(id) ON DELETE CASCADE;


--
-- Name: shared_credentials FK_416f66fc846c7c442970c094ccf; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.shared_credentials
    ADD CONSTRAINT "FK_416f66fc846c7c442970c094ccf" FOREIGN KEY ("credentialsId") REFERENCES public.credentials_entity(id) ON DELETE CASCADE;


--
-- Name: variables FK_42f6c766f9f9d2edcc15bdd6e9b; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.variables
    ADD CONSTRAINT "FK_42f6c766f9f9d2edcc15bdd6e9b" FOREIGN KEY ("projectId") REFERENCES public.project(id) ON DELETE CASCADE;


--
-- Name: chat_hub_agents FK_441ba2caba11e077ce3fbfa2cd8; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.chat_hub_agents
    ADD CONSTRAINT "FK_441ba2caba11e077ce3fbfa2cd8" FOREIGN KEY ("ownerId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: project_relation FK_5f0643f6717905a05164090dde7; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.project_relation
    ADD CONSTRAINT "FK_5f0643f6717905a05164090dde7" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: project_relation FK_61448d56d61802b5dfde5cdb002; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.project_relation
    ADD CONSTRAINT "FK_61448d56d61802b5dfde5cdb002" FOREIGN KEY ("projectId") REFERENCES public.project(id) ON DELETE CASCADE;


--
-- Name: insights_by_period FK_6414cfed98daabbfdd61a1cfbc0; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.insights_by_period
    ADD CONSTRAINT "FK_6414cfed98daabbfdd61a1cfbc0" FOREIGN KEY ("metaId") REFERENCES public.insights_metadata("metaId") ON DELETE CASCADE;


--
-- Name: oauth_authorization_codes FK_64d965bd072ea24fb6da55468cd; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.oauth_authorization_codes
    ADD CONSTRAINT "FK_64d965bd072ea24fb6da55468cd" FOREIGN KEY ("clientId") REFERENCES public.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: chat_hub_messages FK_6afb260449dd7a9b85355d4e0c9; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.chat_hub_messages
    ADD CONSTRAINT "FK_6afb260449dd7a9b85355d4e0c9" FOREIGN KEY ("executionId") REFERENCES public.execution_entity(id) ON DELETE SET NULL;


--
-- Name: insights_raw FK_6e2e33741adef2a7c5d66befa4e; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.insights_raw
    ADD CONSTRAINT "FK_6e2e33741adef2a7c5d66befa4e" FOREIGN KEY ("metaId") REFERENCES public.insights_metadata("metaId") ON DELETE CASCADE;


--
-- Name: oauth_access_tokens FK_7234a36d8e49a1fa85095328845; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT "FK_7234a36d8e49a1fa85095328845" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: installed_nodes FK_73f857fc5dce682cef8a99c11dbddbc969618951; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.installed_nodes
    ADD CONSTRAINT "FK_73f857fc5dce682cef8a99c11dbddbc969618951" FOREIGN KEY (package) REFERENCES public.installed_packages("packageName") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: oauth_access_tokens FK_78b26968132b7e5e45b75876481; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT "FK_78b26968132b7e5e45b75876481" FOREIGN KEY ("clientId") REFERENCES public.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: chat_hub_sessions FK_7bc13b4c7e6afbfaf9be326c189; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.chat_hub_sessions
    ADD CONSTRAINT "FK_7bc13b4c7e6afbfaf9be326c189" FOREIGN KEY ("credentialId") REFERENCES public.credentials_entity(id) ON DELETE SET NULL;


--
-- Name: folder FK_804ea52f6729e3940498bd54d78; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.folder
    ADD CONSTRAINT "FK_804ea52f6729e3940498bd54d78" FOREIGN KEY ("parentFolderId") REFERENCES public.folder(id) ON DELETE CASCADE;


--
-- Name: shared_credentials FK_812c2852270da1247756e77f5a4; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.shared_credentials
    ADD CONSTRAINT "FK_812c2852270da1247756e77f5a4" FOREIGN KEY ("projectId") REFERENCES public.project(id) ON DELETE CASCADE;


--
-- Name: test_case_execution FK_8e4b4774db42f1e6dda3452b2af; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.test_case_execution
    ADD CONSTRAINT "FK_8e4b4774db42f1e6dda3452b2af" FOREIGN KEY ("testRunId") REFERENCES public.test_run(id) ON DELETE CASCADE;


--
-- Name: data_table_column FK_930b6e8faaf88294cef23484160; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.data_table_column
    ADD CONSTRAINT "FK_930b6e8faaf88294cef23484160" FOREIGN KEY ("dataTableId") REFERENCES public.data_table(id) ON DELETE CASCADE;


--
-- Name: folder_tag FK_94a60854e06f2897b2e0d39edba; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.folder_tag
    ADD CONSTRAINT "FK_94a60854e06f2897b2e0d39edba" FOREIGN KEY ("folderId") REFERENCES public.folder(id) ON DELETE CASCADE;


--
-- Name: execution_annotations FK_97f863fa83c4786f19565084960; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.execution_annotations
    ADD CONSTRAINT "FK_97f863fa83c4786f19565084960" FOREIGN KEY ("executionId") REFERENCES public.execution_entity(id) ON DELETE CASCADE;


--
-- Name: chat_hub_agents FK_9c61ad497dcbae499c96a6a78ba; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.chat_hub_agents
    ADD CONSTRAINT "FK_9c61ad497dcbae499c96a6a78ba" FOREIGN KEY ("credentialId") REFERENCES public.credentials_entity(id) ON DELETE SET NULL;


--
-- Name: chat_hub_sessions FK_9f9293d9f552496c40e0d1a8f80; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.chat_hub_sessions
    ADD CONSTRAINT "FK_9f9293d9f552496c40e0d1a8f80" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE SET NULL;


--
-- Name: execution_annotation_tags FK_a3697779b366e131b2bbdae2976; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.execution_annotation_tags
    ADD CONSTRAINT "FK_a3697779b366e131b2bbdae2976" FOREIGN KEY ("tagId") REFERENCES public.annotation_tag_entity(id) ON DELETE CASCADE;


--
-- Name: shared_workflow FK_a45ea5f27bcfdc21af9b4188560; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.shared_workflow
    ADD CONSTRAINT "FK_a45ea5f27bcfdc21af9b4188560" FOREIGN KEY ("projectId") REFERENCES public.project(id) ON DELETE CASCADE;


--
-- Name: workflow_dependency FK_a4ff2d9b9628ea988fa9e7d0bf8; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.workflow_dependency
    ADD CONSTRAINT "FK_a4ff2d9b9628ea988fa9e7d0bf8" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: oauth_user_consents FK_a651acea2f6c97f8c4514935486; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.oauth_user_consents
    ADD CONSTRAINT "FK_a651acea2f6c97f8c4514935486" FOREIGN KEY ("clientId") REFERENCES public.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_refresh_tokens FK_a699f3ed9fd0c1b19bc2608ac53; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.oauth_refresh_tokens
    ADD CONSTRAINT "FK_a699f3ed9fd0c1b19bc2608ac53" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: folder FK_a8260b0b36939c6247f385b8221; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.folder
    ADD CONSTRAINT "FK_a8260b0b36939c6247f385b8221" FOREIGN KEY ("projectId") REFERENCES public.project(id) ON DELETE CASCADE;


--
-- Name: oauth_authorization_codes FK_aa8d3560484944c19bdf79ffa16; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.oauth_authorization_codes
    ADD CONSTRAINT "FK_aa8d3560484944c19bdf79ffa16" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: chat_hub_messages FK_acf8926098f063cdbbad8497fd1; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.chat_hub_messages
    ADD CONSTRAINT "FK_acf8926098f063cdbbad8497fd1" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE SET NULL;


--
-- Name: oauth_refresh_tokens FK_b388696ce4d8be7ffbe8d3e4b69; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.oauth_refresh_tokens
    ADD CONSTRAINT "FK_b388696ce4d8be7ffbe8d3e4b69" FOREIGN KEY ("clientId") REFERENCES public.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: execution_annotation_tags FK_c1519757391996eb06064f0e7c8; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.execution_annotation_tags
    ADD CONSTRAINT "FK_c1519757391996eb06064f0e7c8" FOREIGN KEY ("annotationId") REFERENCES public.execution_annotations(id) ON DELETE CASCADE;


--
-- Name: data_table FK_c2a794257dee48af7c9abf681de; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.data_table
    ADD CONSTRAINT "FK_c2a794257dee48af7c9abf681de" FOREIGN KEY ("projectId") REFERENCES public.project(id) ON DELETE CASCADE;


--
-- Name: project_relation FK_c6b99592dc96b0d836d7a21db91; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.project_relation
    ADD CONSTRAINT "FK_c6b99592dc96b0d836d7a21db91" FOREIGN KEY (role) REFERENCES public.role(slug);


--
-- Name: test_run FK_d6870d3b6e4c185d33926f423c8; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.test_run
    ADD CONSTRAINT "FK_d6870d3b6e4c185d33926f423c8" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: shared_workflow FK_daa206a04983d47d0a9c34649ce; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.shared_workflow
    ADD CONSTRAINT "FK_daa206a04983d47d0a9c34649ce" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: folder_tag FK_dc88164176283de80af47621746; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.folder_tag
    ADD CONSTRAINT "FK_dc88164176283de80af47621746" FOREIGN KEY ("tagId") REFERENCES public.tag_entity(id) ON DELETE CASCADE;


--
-- Name: user_api_keys FK_e131705cbbc8fb589889b02d457; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.user_api_keys
    ADD CONSTRAINT "FK_e131705cbbc8fb589889b02d457" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: chat_hub_messages FK_e22538eb50a71a17954cd7e076c; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.chat_hub_messages
    ADD CONSTRAINT "FK_e22538eb50a71a17954cd7e076c" FOREIGN KEY ("sessionId") REFERENCES public.chat_hub_sessions(id) ON DELETE CASCADE;


--
-- Name: test_case_execution FK_e48965fac35d0f5b9e7f51d8c44; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.test_case_execution
    ADD CONSTRAINT "FK_e48965fac35d0f5b9e7f51d8c44" FOREIGN KEY ("executionId") REFERENCES public.execution_entity(id) ON DELETE SET NULL;


--
-- Name: chat_hub_messages FK_e5d1fa722c5a8d38ac204746662; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.chat_hub_messages
    ADD CONSTRAINT "FK_e5d1fa722c5a8d38ac204746662" FOREIGN KEY ("previousMessageId") REFERENCES public.chat_hub_messages(id) ON DELETE CASCADE;


--
-- Name: chat_hub_sessions FK_e9ecf8ede7d989fcd18790fe36a; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.chat_hub_sessions
    ADD CONSTRAINT "FK_e9ecf8ede7d989fcd18790fe36a" FOREIGN KEY ("ownerId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: user FK_eaea92ee7bfb9c1b6cd01505d56; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT "FK_eaea92ee7bfb9c1b6cd01505d56" FOREIGN KEY ("roleSlug") REFERENCES public.role(slug);


--
-- Name: role_scope FK_role; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.role_scope
    ADD CONSTRAINT "FK_role" FOREIGN KEY ("roleSlug") REFERENCES public.role(slug) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: role_scope FK_scope; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.role_scope
    ADD CONSTRAINT "FK_scope" FOREIGN KEY ("scopeSlug") REFERENCES public.scope(slug) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: auth_identity auth_identity_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.auth_identity
    ADD CONSTRAINT "auth_identity_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."user"(id);


--
-- Name: conversations conversations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: execution_data execution_data_fk; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.execution_data
    ADD CONSTRAINT execution_data_fk FOREIGN KEY ("executionId") REFERENCES public.execution_entity(id) ON DELETE CASCADE;


--
-- Name: execution_entity fk_execution_entity_workflow_id; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.execution_entity
    ADD CONSTRAINT fk_execution_entity_workflow_id FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: webhook_entity fk_webhook_entity_workflow_id; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.webhook_entity
    ADD CONSTRAINT fk_webhook_entity_workflow_id FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: workflow_entity fk_workflow_parent_folder; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.workflow_entity
    ADD CONSTRAINT fk_workflow_parent_folder FOREIGN KEY ("parentFolderId") REFERENCES public.folder(id) ON DELETE CASCADE;


--
-- Name: workflow_statistics fk_workflow_statistics_workflow_id; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.workflow_statistics
    ADD CONSTRAINT fk_workflow_statistics_workflow_id FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: workflows_tags fk_workflows_tags_tag_id; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.workflows_tags
    ADD CONSTRAINT fk_workflows_tags_tag_id FOREIGN KEY ("tagId") REFERENCES public.tag_entity(id) ON DELETE CASCADE;


--
-- Name: workflows_tags fk_workflows_tags_workflow_id; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.workflows_tags
    ADD CONSTRAINT fk_workflows_tags_workflow_id FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: messages messages_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(conversation_id) ON DELETE CASCADE;


--
-- Name: messages messages_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- Name: user_token_usage user_token_usage_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: widip
--

ALTER TABLE ONLY public.user_token_usage
    ADD CONSTRAINT user_token_usage_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict zzcwbK87BrutcG5idwLSeW6MIn24OsXUtctssEp8Azkjg7I2sogeK32vohvY7cy

